# Setting Up a Server for a Laravel Project

This guide provides instructions to set up an **Ubuntu Nginx Server** for deploying your **Laravel Project** from **GitHub**. Follow the steps below to easily deploy your Laravel project using the provided script.

## Run the Setup Script
Execute the script to set up your server and deploy your Laravel project:

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/muhaiminShihab/project-deployment/main/setup.sh)"
   ```

## Script Information
During execution, the script will prompt you for the following details:
- **Project Name**  
- **PHP Version**  
- **GitHub Repository URL**  
- **Database Username and Password**  
- **Domain Name**

Once the setup is completed, your server will be configured, and your Laravel project will be deployed successfully.
