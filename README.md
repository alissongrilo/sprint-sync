SprintSync is a simple yet useful tool designed to streamline the process of analyzing squad data.

Currently, the API connects directly to Azure DevOps and retrieves pull requests in real time.
This eliminates the need to navigate the Azure DevOps interface and allows for quick access to relevant data for analysis.

📌 Roadmap

[ ] Store pull requests in a local database (Avoid direct and repeated access to Azure DevOps)

[ ] Create a background job system using Sidekiq for asynchronous data synchronization

[ ] Add support for GitHub integration
