# Setting Up a Server for a Laravel Project

This guide provides instructions to set up an **Ubuntu Nginx Server** for deploying your **Laravel Project** from **GitHub**. Follow the steps below to easily deploy your Laravel project using the provided script.

## Steps to Set Up Your Server

1. **Clone the Repository**
   Fetch the setup script from GitHub to your server by running:
   ```shell
   git clone https://github.com/muhaiminShihab/project-deployment.git
   ```

2. **Navigate to the Project Folder**
   Move into the downloaded repository:
   ```shell
   cd project-deployment
   ```
   Inside this folder, you will find a file named `setup.sh`.

3. **Make the Script Executable**
   Grant execution permissions to the setup script:
   ```shell
   sudo chmod +x setup.sh
   ```

4. **Run the Setup Script**
   Execute the script to set up your server and deploy your Laravel project:
   ```shell
   sudo ./setup.sh
   ```

   > **Note:** Ensure the filename is correct. If the script name is different, adjust the command accordingly.

## Script Information
During execution, the script will prompt you for the following details:
- **Project Name**  
- **PHP Version**  
- **GitHub Repository URL**  
- **Database Username and Password**  
- **Domain Name**

Once the setup is completed, your server will be configured, and your Laravel project will be deployed successfully.
