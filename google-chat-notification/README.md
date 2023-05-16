# Google Chat Notification GitHub Action

## Usage

Add `google-chat-notification.yml` to `.github/workflows/`

```yml
name: Google Chat Notification
on:
  pull_request:
    types: [opened, reopened, closed]
  pull_request_review_comment:
    types: [created]

jobs:
  notify:
    runs-on: ubuntu-latest
    steps:
      - name: Google Chat Notification
        uses: trimble-oss/gh-actions/google-chat-notification@main
        with:
          url: ${{ secrets.GOOGLE_CHAT_WEBHOOK }}
```

## Credits

- [CommonMarvel - google-chat-notification](https://github.com/CommonMarvel/google-chat-notification/).
