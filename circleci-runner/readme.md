# CircleCI Runner

Image of a primary container that runs our tests on CircleCI 2.0. See `.circle/config.yml` in the Main project.

## Building and publishing

1) Make some changes to the `Dockerfile`.
2) Run this:
    ```bash
    docker build -t lidskasila/circleci-runner .
    ```
3) When you're happy with the result, tag the new version (replace `1.2` with the actual version):
    ```bash
    docker tag lidskasila/circleci-runner lidskasila/circleci-runner:1.2
    ```
    
4) Publish on Docker Hub:
    ```bash
    docker push lidskasila/circleci-runner
    ```
    If you don't have write access to the Hub, ask someone who does.
    
5) Edit the image version in `.circle/config.yml` in the Main project.
