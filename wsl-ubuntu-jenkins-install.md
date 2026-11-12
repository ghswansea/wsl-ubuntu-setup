To run Jenkins smoothly inside your **WSL2 Ubuntu 24.04** environment (without Docker Desktop), you need two WSL2-specific adjustments: using your native Ubuntu terminal instead of PowerShell, and matching the Ubuntu host's `docker` group ID so the Jenkins container has permission to use `/var/run/docker.sock`.

Here is the complete, updated workflow tailored specifically for your **Ubuntu 24.04 WSL2** setup, from starting Jenkins to running your Python pipeline via GitHub.

---

### Part 1: Start Jenkins in WSL2 Ubuntu 24.04

Run these steps inside your **Ubuntu 24.04 terminal** (as user `hua`, now that you are in the `docker` group):

1. **Start the Jenkins container**
Run the standard container launch command in your Ubuntu terminal:
```bash
docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --name my-jenkins jenkins/jenkins:lts

```


* *Verification:* Run `docker ps`. You should see `my-jenkins` listed with status `Up`.


2. **Install the Docker CLI inside the Jenkins container**
Install `docker.io` inside `my-jenkins` as `root` (`-u 0`) so Jenkins can execute `docker build` and `docker run` commands:
```bash
docker exec -u 0 my-jenkins apt-get update && docker exec -u 0 my-jenkins apt-get install -y docker.io

```


* *Verification:* Run `docker exec my-jenkins docker --version`. It should print a Docker version string without a "command not found" error.


3. **Grant Jenkins permission to use the Ubuntu Docker socket**
On native Ubuntu 24.04, `/var/run/docker.sock` is owned by the host's `docker` group ID (GID). Add the `jenkins` user inside the container to that exact same GID:
```bash
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
docker exec -u 0 my-jenkins groupadd -for -g "$DOCKER_GID" docker
docker exec -u 0 my-jenkins usermod -aG docker jenkins
docker restart my-jenkins

```


* *Verification:* Run `docker exec my-jenkins docker ps` (without `-u 0`). If it lists your running containers instead of showing a `permission denied` error, Jenkins can now control Docker properly.


4. **Retrieve the initial admin password and unlock Jenkins**
Print the setup key in Ubuntu:
```bash
docker exec my-jenkins cat /var/jenkins_home/secrets/initialAdminPassword

```


Open **Chrome or Edge on Windows 11**, navigate to **`http://localhost:8080`** (WSL2 forwards this port automatically), paste the password, click **Install suggested plugins**, and create your admin user.
* *Verification:* You land on the main Jenkins Dashboard in your Windows browser.



---

### Part 2: Create Your Python Project in Ubuntu & Push to GitHub

Keep your project inside your native Ubuntu home directory (`~/`) rather than `/mnt/c/` for fast Docker builds.

1. **Create the project directory and Python script**
In your Ubuntu 24.04 terminal:
```bash
mkdir -p ~/projects/my-python-app
cd ~/projects/my-python-app

```


Create `app.py`:
```bash
cat << 'EOF' > app.py
def greet(name: str) -> str:
    return f"Hello, {name}! Running inside Docker via Jenkins on WSL2."

if __name__ == "__main__":
    print(greet("Hua"))
EOF

```


* *Verification:* Run `python3 app.py` to confirm it prints the greeting cleanly.


2. **Create the `Dockerfile**`
In the same `~/projects/my-python-app` directory, create `Dockerfile`:
```bash
cat << 'EOF' > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
EOF

```


* *Verification:* Run `cat Dockerfile` to verify the four lines are properly formatted on separate lines.


3. **Create the `Jenkinsfile**`
Create `Jenkinsfile` (exact capitalization, no file extension):
```bash
cat << 'EOF' > Jenkinsfile
pipeline {
    agent any
    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t my-python-app:${BUILD_NUMBER} .'
            }
        }
        stage('Run Container Test') {
            steps {
                sh 'docker run --rm my-python-app:${BUILD_NUMBER}'
            }
        }
    }
    post {
        always {
            sh 'docker rmi my-python-app:${BUILD_NUMBER} || true'
        }
    }
}
EOF

```


*(The `post` block cleans up the test image after every build so your WSL2 disk doesn't fill up.)*
* *Verification:* Run `ls -la` inside `~/projects/my-python-app`. You should see `app.py`, `Dockerfile`, and `Jenkinsfile`.


4. **Initialize Git and push to GitHub**
Create an empty repository on GitHub (for example, `[https://github.com/](https://github.com/)<your-username>/my-python-app.git`), then push your files from Ubuntu:
```bash
git init -b main
git add app.py Dockerfile Jenkinsfile
git commit -m "Initial commit: Python app, Dockerfile, and Jenkinsfile"
git remote add origin https://github.com/<your-username>/my-python-app.git
git push -u origin main

```


* *Verification:* Refresh your GitHub repository page in your browser and confirm `app.py`, `Dockerfile`, and `Jenkinsfile` appear in the `main` branch.



---

### Part 3: Connect Jenkins to Your GitHub Repository

1. **Create a new Pipeline job**
In Jenkins (`http://localhost:8080`), click **+ New Item** on the left sidebar, enter `my-python-app`, select **Pipeline**, and click **OK**.
2. **Link your GitHub repository**
Scroll down to the **Pipeline** section at the bottom of the configuration page:
* Set **Definition** to **Pipeline script from SCM**.
* Set **SCM** to **Git**.
* Paste your GitHub repository URL (`[https://github.com/](https://github.com/)<your-username>/my-python-app.git`) into **Repository URL**. *(If the repo is private, click **Add -> Jenkins** under Credentials and enter your GitHub username and a GitHub Personal Access Token).*
* Confirm **Branch Specifier** is set to `*/main`.
* Confirm **Script Path** is `Jenkinsfile`.


3. **Save and trigger your first build**
Click **Save**, then click **Build Now** on the left menu.
* *Verification:* Click the build number (e.g., `#1`) under **Build History**, then click **Console Output**. You will see Jenkins clone your GitHub repo, build the Docker image, print `Hello, Hua! Running inside Docker via Jenkins on WSL2.`, and finish with `Finished: SUCCESS`.