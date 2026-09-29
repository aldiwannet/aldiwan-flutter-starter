# Security policy

Please report vulnerabilities privately through GitHub Security Advisories. Do not open a public issue. Never commit API keys, tokens, or production responses containing personal data.

Values passed with `--dart-define` are compiled into client binaries and are not secrets. Use only a limited development key this way; put production authenticated calls behind your own trusted backend.
