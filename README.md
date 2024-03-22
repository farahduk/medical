# Pub Med Medical API Y_A_L_E B_I_D_S assessment

Application to retrieve information from PubMed API with a user-friendly UI. API requests are made in background tasks to avoid timeouts.

Using Docker to containerize the application facilitates easy deployments to any host or platform we decide to deploy on. Currently, only the development stage has been developed, but any other stages (such as testing, staging, and production) can be easily implemented from the current structure.

## Developing

### Starting The Application

Simply open a new terminal on your machine and execute the following command:

```bash
make start
```

This will build or pull the appropriate images and start the desired services (containers) to run the application.

You can then open a new tab in your preferred browser and navigate to [http://localhost:5000](http://localhost:5000)


A form will be displayed with two inputs:

*Search: where you can perform a new search on the PubMed API. A new background task will be created, and a link to retrieve the status of the task will be displayed below the input. You can click on that link, and a new browser tab will open with the task state.
*Fetch: If you have the task ID, you can directly check the status of that task through this input instead.

Press `CTRL + C` to stop the running application.

### Adding new dependencies

For handling dependencies, the Poetry tool is being used. Go to https://python-poetry.org/docs/#installation for specific OS installation instructions.

After poetry is properly installed, you can add new dependencies by running:

```bash
poetry add name-of-library
```

### API URLs

Search: http://localhost:5000/search/?term=

Fetch: http://localhost:5000/fetch/