# Dependency cache update

## discourse-bundler

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 6.1.0 | 4 | 0 | 4.299 | 3.365 | 3.251 | 540 | 3.6 | 540 | 1177 | 37004.0 |
| actions-cache | depot | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 2.546 | 2.437 | 7.39 | 565 | 2.619 | 566 | 1177 | 37004 |
| actions-cache | depot | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 3 | 0 | 2.574 | 8.043 | 7.49 | 565 | 2.514 | 569 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 6.1.0 | 1 | 0 | 7.557 | 6.298 | 6.001 | 567 | 5.826 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 7.993 | 7.171 | 6.245 | 565 | 7.757 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 6.746 | 5.812 | 5.115 | 565 | 6.855 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 6.1.0 | 1 | 0 | 5.655 | 5.194 | 4.453 | 565 | 7.623 | 565 | 1177 | 37004 |
| actions-cache | github | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 2 | 0 | 7.775 | 6.735 | 6.123 | 566 | 8.217 | 542 | 1177 | 37004.0 |
| actions-cache | github | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 6.1.0 | 2 | 0 | 6.201 | 5.503 | 4.784 | 565 | 8.76 | 542 | 1177 | 37004.0 |
| actions-cache | github | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 6.1.0 | 4 | 0 | 8.108 | 3.016 | 3.855 | 547 | 8.484 | 542 | 1177 | 37004.0 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.1 | 2 | 0 | 6.896 | 3.286 | 5.026 | 19 | 5.698 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | Intel(R) Xeon(R) Processor | 1.43.2 | 1 | 0 | 6.242 | 3.313 | 4.624 | 16 | 5.598 | 534 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | Intel(R) Xeon(R) Processor | AMD EPYC | 1.44.0 | 1 | 0 | 6.861 | 2.159 | 4.872 | 16 | 6.897 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 6.091 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 5.412 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 6.149 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 6.021 | 515 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 4.016 | 2.679 | 2.866 | 16 | 3.804 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 4.494 | 2.807 | 3.517 | 26 | 3.748 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 4.106 | 3.18 | 2.865 | 16 | 3.587 | 540 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 4.281 | 2.595 | 2.557 | 16 | 3.692 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 3.414 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 4.144 | 537 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 5.788 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 3.668 | 539 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 9.059 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 7.846 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | INTEL(R) XEON(R) PLATINUM 8573C | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 6.449 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 7763 64-Core Processor | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 7.817 | 536 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 6.071 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 5.514 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 5.777 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 5.62 | 514 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.1 | 2 | 0 | 5.928 | 3.954 | 3.735 | 16 | 5.315 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 5.856 | 3.657 | 3.603 | 16 | 5.757 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 7.157 | 3.222 | 3.181 | 16 | 5.93 | 515 | 1177 | 37004 |

## mastodon-bundler

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 1.042 | 2.971 | 1.602 | 82 | 1.38 | 82 | 190 | 19550 |
| actions-cache | depot | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 1.6 | 2.185 | 1.648 | 85 | 1.214 | 85 | 190 | 19550 |
| actions-cache | depot | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 2 | 0 | 1.167 | 2.465 | 1.645 | 85 | 1.125 | 86 | 190 | 19550.0 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 1.788 | 4.208 | 2.523 | 86 | 3.464 | 86 | 190 | 19550 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 2 | 0 | 2.741 | 5.256 | 3.281 | 86 | 2.519 | 86 | 190 | 19550.0 |
| actions-cache | github | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 3 | 0 | 2.444 | 4.208 | 3.042 | 86 | 2.105 | 82 | 190 | 19550 |
| actions-cache | github | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 1.941 | 2.78 | 2.342 | 82 | 2.151 | 82 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 2.884 | 2.502 | 3.857 | 7 | 3.618 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 3.262 | 2.924 | 3.767 | 5 | 3.14 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 3.957 | 2.602 | 3.885 | 5 | 3.46 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 3.136 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 3.092 | 87 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 3.518 | 84 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 2.144 | 2.315 | 2.317 | 5 | 1.741 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 1.673 | 2.905 | 2.156 | 5 | 1.589 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 1.985 | 2.43 | 1.982 | 5 | 1.59 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 1.62 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 1.758 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 1.571 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 2.485 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 2.501 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC 7763 64-Core Processor | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 2.621 | 88 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 3.977 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 2.561 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 2.619 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 2.814 | 2.854 | 2.798 | 5 | 2.185 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 2.94 | 3.232 | 2.4 | 5 | 2.163 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 2.942 | 3.695 | 2.305 | 5 | 2.157 | 84 | 190 | 19550 |

## posthog-pnpm

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 9.579 | 5.612 | 7.011 | 723 | 15.485 | 725 | 2721 | 163161 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | Intel(R) Xeon(R) Processor | 6.1.0 | 1 | 0 | 6.744 | 3.943 | 5.194 | 723 | 10.531 | 724 | 2721 | 163161 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | Intel(R) Xeon(R) Processor | AMD EPYC | 6.1.0 | 1 | 0 | 7.555 | 3.286 | 4.965 | 723 | 5.876 | 724 | 2721 | 163161 |
| actions-cache | actions-cache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 5.682 | 3.599 | 12.236 | 750 | 5.824 | 761 | 2721 | 163161 |
| actions-cache | depot | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 11.717 | 7.144 | 10.511 | 759 | 5.68 | 763 | 2721 | 163161 |
| actions-cache | depot | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 2 | 0 | 4.792 | 3.069 | 10.898 | 782 | 5.181 | 758 | 2721 | 163161.0 |
| actions-cache | actions-cache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 18.573 | 21.919 | 8.717 | 757 | 19.995 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 14.999 | 13.806 | 11.468 | 757 | 13.168 | 752 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 17.173 | 14.167 | 17.298 | 757 | 17.211 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 6.1.0 | 1 | 0 | 15.676 | 13.171 | 12.399 | 757 | 13.084 | 757 | 2721 | 163161 |
| actions-cache | github | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 3 | 0 | 15.676 | 13.806 | 12.399 | 757 | 18.696 | 726 | 2721 | 163161 |
| actions-cache | actions-cache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 18.612 | 4.992 | 7.441 | 736 | 20.895 | 725 | 2721 | 163161 |
| actions-cache | github | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 18.73 | 4.978 | 7.363 | 729 | 18.725 | 725 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 10.315 | 3.745 | 9.481 | 72 | 10.024 | 817 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 10.478 | 3.374 | 9.38 | 73 | 9.257 | 815 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 13.976 | 4.134 | 11.761 | 74 | 10.562 | 819 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 10.034 | 816 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 12.462 | 819 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 11.317 | 817 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 | 1.43.1 | 1 | 0 | 12.926 | 3.349 | 6.025 | 76 | 11.532 | 843 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.42.2 | 1 | 0 | 10.06 | 3.274 | 6.539 | 75 | 9.528 | 861 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 8.912 | 3.651 | 7.407 | 76 | 7.087 | 857 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 9.675 | 3.037 | 7.538 | 76 | 7.841 | 862 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 8.435 | 859 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 6.293 | 865 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 7.137 | 857 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 12.908 | 852 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 17.105 | 849 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 1.42.2 | 1 | 0 | 19.344 | 17.308 | 8.94 | 76 | 23.707 | 849 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 14.762 | 850 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 13.319 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 12.138 | 818 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 11.335 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.42.2 | 1 | 0 | 22.116 | 4.877 | 6.772 | 73 | 20.184 | 816 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 10.912 | 4.686 | 6.782 | 72 | 11.851 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 13.419 | 5.691 | 7.66 | 74 | 11.215 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 12.897 | 4.843 | 18.724 | 78 | 13.887 | 817 | 2721 | 163161 |

## posthog-uv

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 2 | 0 | 7.647 | 0.794 | 6.182 | 997 | 8.489 | 999 | 3582 | 66741.5 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | Intel(R) Xeon(R) Processor | 6.1.0 | 1 | 0 | 13.382 | 1.297 | 8.241 | 997 | 6.699 | 998 | 3582 | 66757 |
| actions-cache | actions-cache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 5.804 | 0.82 | 14.111 | 1045 | 6.02 | 1044 | 3582 | 66731 |
| actions-cache | depot | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 12.682 | 1.157 | 13.642 | 1036 | 6.553 | 1055 | 3582 | 66733 |
| actions-cache | depot | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 2 | 0 | 5.388 | 0.844 | 13.937 | 1043 | 5.714 | 1043 | 3582 | 66755.5 |
| actions-cache | actions-cache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 19.525 | 4.071 | 9.495 | 1043 | 18.249 | 1043 | 3582 | 66731 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 2 | 0 | 16.77 | 2.638 | 13.742 | 1044 | 14.282 | 1044 | 3582 | 66744.0 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | INTEL(R) XEON(R) PLATINUM 8573C | Intel(R) Xeon(R) 6973P-C | 6.1.0 | 1 | 0 | 21.923 | 3.619 | 11.811 | 1043 | 32.551 | 1043 | 3582 | 66752 |
| actions-cache | github | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 2 | 0 | 16.77 | 2.638 | 13.742 | 1044 | 20.393 | 1001 | 3582 | 66744.0 |
| actions-cache | github | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 6.1.0 | 1 | 0 | 21.923 | 3.619 | 11.811 | 1043 | 18.165 | 1000 | 3582 | 66752 |
| actions-cache | actions-cache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 18.78 | 0.91 | 10.218 | 1004 | 20.631 | 1001 | 3582 | 66727 |
| actions-cache | github | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 18.683 | 0.947 | 7.314 | 1006 | 19.279 | 1000 | 3582 | 66752 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 8.434 | 0.859 | 6.739 | 27 | 11.355 | 1013 | 3582 | 66731 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.3 | 1 | 0 | 11.031 | 0.73 | 12.847 | 29 | 11.775 | 1013 | 3582 | 66752 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 10.786 | 1.053 | 8.604 | 31 | 12.951 | 1017 | 3582 | 66757 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 10.578 | 1012 | 3582 | 66731 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 10.237 | 1013 | 3582 | 66752 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 9.68 | 1012 | 3582 | 66757 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 11.734 | 1.167 | 4.7 | 32 | 7.071 | 1067 | 3582 | 66732 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.42.2 | 1 | 0 | 10.917 | 0.793 | 4.419 | 28 | 7.445 | 1063 | 3582 | 66731 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.3 | 1 | 0 | 7.435 | 0.843 | 10.033 | 29 | 6.734 | 1060 | 3582 | 66752 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 6.503 | 0.761 | 3.83 | 33 | 6.016 | 1063 | 3582 | 66757 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 9.346 | 1045 | 3582 | 66752 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 8.842 | 1061 | 3582 | 66731 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 6.284 | 1065 | 3582 | 66757 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 12.894 | 1055 | 3582 | 66752 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 16.713 | 1053 | 3582 | 66731 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 21.189 | 1053 | 3582 | 66757 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) 6973P-C | AMD EPYC 7763 64-Core Processor | 1.42.2 | 1 | 0 | 17.797 | 6.236 | 6.465 | 32 | 17.33 | 1053 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 11.042 | 1010 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 14.579 | 1011 | 3582 | 66752 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 13.755 | 1013 | 3582 | 66757 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.42.2 | 1 | 0 | 18.967 | 0.935 | 4.672 | 33 | 16.456 | 1011 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 11.093 | 0.989 | 4.609 | 29 | 11.018 | 1010 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.3 | 1 | 0 | 13.316 | 1.039 | 12.611 | 36 | 12.319 | 1011 | 3582 | 66752 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 12.682 | 1.148 | 4.774 | 29 | 14.775 | 1011 | 3582 | 66757 |
