# Download Slack Emoji

## Requirements

- Ruby 3.0.2+
- Access to the settings panel for your Slack workspace

Inspect the network requests when you navigate to the going to the admin panel for you Slack workspace settings page.

The payload looks like:

```json
{ "ok": true, "emoji": { "rip": "https://emoji.slack-edge.com/foo/rip/bar.png" } }
```

Save the file as `slack_emoji_response.json`, and store it alongside THIS script.

## Usage

`ruby script.rb -f <path-to-json-file> -b <buffer-size>`

To find out how the flags work:

`ruby script.rb -h`
