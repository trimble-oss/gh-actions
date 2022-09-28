# Mend (formerly WhiteSource) Security Scan GitHub Action

A GitHub Action which uses the [Mend Unified Agent](https://docs.mend.io/bundle/unified_agent/page/overview_of_the_unified_agent.html) to scan a given repository.

## Parameters

See the [action.yml](action.yml) inputs section for the parameter descriptions.

## Usage

### Example Usage (Quick Setup without Config File)

Uses the Auto Resolve Dependencies flag.
You must have the WhiteSource API key set in your GitHub secrets.

```yaml
name: WhiteSource Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v3

      - name: Run WhiteSource Action
        uses: trimble-oss/gh-actions/whitesource-scan@main
        with:
          apiKey: ${{ secrets.WSS_API_KEY }}
          productName: "ExampleProductName"
          projectName: "ExampleProjectName"
```

### Example Usage (With Config File)

```yaml
name: WhiteSource Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read

    steps:
      - uses: actions/checkout@v3

      - name: Run WhiteSource Action
        uses: trimble-oss/gh-actions/mend-scanner@main
        with:
          apiKey: ${{ secrets.WSS_API_KEY }}
          configFile: "wss-unified-agent.config"
```

## More

For more help on how to create a GitHub Action workflow please refer to [GitHub docs](https://docs.github.com/en/actions/quickstart).

## Credits

Originally developed by [TheAxZim/Whitesource-Scan-Action](https://github.com/TheAxZim/Whitesource-Scan-Action).
