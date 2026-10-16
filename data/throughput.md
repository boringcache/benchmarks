# Cache throughput

## Independent consumer

| Lane | Data | Producer | Runner | Version | Samples | Failed | Restore median s | p10–p90 s | Restore network MB | Second restore median s | p10–p90 s | Second restore network MB | Login s |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | compressible | depot 4c | depot 4c | 6.1.0 | 1 | 0 | 7.153 | 7.153–7.153 | 1398 | 7.011 | 7.011–7.011 | 1398 | - |
| actions-cache | compressible | github 4c | github 4c | 6.1.0 | 1 | 0 | 23.543 | 23.543–23.543 | 1396 | 20.299 | 20.299–20.299 | 1396 | - |
| actions-cache | compressible | github 4c | github arm 4c | 6.1.0 | 1 | 0 | 17.533 | 17.533–17.533 | 1400 | 15.768 | 15.768–15.768 | 1401 | - |
| actions-cache | compressible | github 4c | namespace 4c | 6.1.0 | 1 | 0 | 41.263 | 41.263–41.263 | 1340 | 34.852 | 34.852–34.852 | 1339 | - |
| actions-cache | compressible | namespace 4c | github 4c | 6.1.0 | 1 | 0 | 18.645 | 18.645–18.645 | 1396 | 16.985 | 16.985–16.985 | 1396 | - |
| actions-cache | compressible | namespace 4c | namespace 4c | 6.1.0 | 1 | 0 | 64.701 | 64.701–64.701 | 1339 | 57.765 | 57.765–57.765 | 1339 | - |
| actions-cache | random | depot 4c | depot 4c | 6.1.0 | 1 | 0 | 10.465 | 10.465–10.465 | 4518 | 9.9 | 9.9–9.9 | 4517 | - |
| actions-cache | random | github 4c | github 4c | 6.1.0 | 1 | 0 | 41.754 | 41.754–41.754 | 4502 | 40.075 | 40.075–40.075 | 4501 | - |
| actions-cache | random | github 4c | github arm 4c | 6.1.0 | 1 | 0 | 36.409 | 36.409–36.409 | 4501 | 35.209 | 35.209–35.209 | 4501 | - |
| actions-cache | random | github 4c | namespace 4c | 6.1.0 | 1 | 0 | 179.008 | 179.008–179.008 | 4318 | 209.446 | 209.446–209.446 | 4321 | - |
| actions-cache | random | namespace 4c | github 4c | 6.1.0 | 1 | 0 | 40.066 | 40.066–40.066 | 4501 | 37.201 | 37.201–37.201 | 4501 | - |
| actions-cache | random | namespace 4c | namespace 4c | 6.1.0 | 1 | 0 | 94.524 | 94.524–94.524 | 4317 | 98.111 | 98.111–98.111 | 4319 | - |
| boringcache | compressible | depot 4c | depot 4c | 1.42.0 | 1 | 0 | 9.16 | 9.16–9.16 | 1409 | 5.773 | 5.773–5.773 | 1411 | 0.211 |
| boringcache | compressible | depot 4c | github 4c | 1.42.0 | 1 | 0 | 16.933 | 16.933–16.933 | 1398 | 17.026 | 17.026–17.026 | 1398 | 0.364 |
| boringcache | compressible | github 4c | depot 4c | 1.42.0 | 1 | 0 | 9.92 | 9.92–9.92 | 1405 | 5.91 | 5.91–5.91 | 1406 | 0.232 |
| boringcache | compressible | github 4c | github 4c | 1.42.0 | 1 | 0 | 12.289 | 12.289–12.289 | 1399 | 14.77 | 14.77–14.77 | 1398 | 0.381 |
| boringcache | compressible | github 4c | github arm 4c | 1.42.0 | 1 | 0 | 13.665 | 13.665–13.665 | 1398 | 13.191 | 13.191–13.191 | 1398 | 0.843 |
| boringcache | compressible | github 4c | namespace 4c | 1.42.0 | 1 | 0 | 8.694 | 8.694–8.694 | 1342 | 6.735 | 6.735–6.735 | 1343 | 0.408 |
| boringcache | compressible | namespace 4c | github 4c | 1.42.0 | 1 | 0 | 11.798 | 11.798–11.798 | 1401 | 10.606 | 10.606–10.606 | 1401 | 0.556 |
| boringcache | compressible | namespace 4c | namespace 4c | 1.42.0 | 1 | 0 | 7.645 | 7.645–7.645 | 1342 | 6.305 | 6.305–6.305 | 1342 | 0.376 |
| boringcache | random | depot 4c | depot 4c | 1.42.0 | 1 | 0 | 9.151 | 9.151–9.151 | 4521 | 8.854 | 8.854–8.854 | 4515 | 0.216 |
| boringcache | random | depot 4c | github 4c | 1.42.0 | 1 | 0 | 21.284 | 21.284–21.284 | 4503 | 18.894 | 18.894–18.894 | 4507 | 0.672 |
| boringcache | random | github 4c | depot 4c | 1.42.0 | 1 | 0 | 11.222 | 11.222–11.222 | 4512 | 8.446 | 8.446–8.446 | 4513 | 0.201 |
| boringcache | random | github 4c | github 4c | 1.42.0 | 1 | 0 | 19.135 | 19.135–19.135 | 4506 | 16.756 | 16.756–16.756 | 4510 | 0.684 |
| boringcache | random | github 4c | github arm 4c | 1.42.0 | 1 | 0 | 15.529 | 15.529–15.529 | 4512 | 13.063 | 13.063–13.063 | 4510 | 0.413 |
| boringcache | random | github 4c | namespace 4c | 1.42.0 | 1 | 0 | 8.534 | 8.534–8.534 | 4318 | 7.474 | 7.474–7.474 | 4319 | 0.417 |
| boringcache | random | namespace 4c | github 4c | 1.42.0 | 1 | 0 | 14.805 | 14.805–14.805 | 4503 | 14.004 | 14.004–14.004 | 4527 | 0.706 |
| boringcache | random | namespace 4c | namespace 4c | 1.42.0 | 1 | 0 | 10.55 | 10.55–10.55 | 4320 | 7.593 | 7.593–7.593 | 4320 | 0.393 |

## Producer save

| Lane | Data | Runner | Version | Samples | Failed | Save median s | p10–p90 s | Save network MB | Login s |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | compressible | depot 4c | 6.1.0 | 1 | 0 | 17.988 | 17.988–17.988 | 1402 | - |
| actions-cache | compressible | github 4c | 6.1.0 | 1 | 0 | 18.367 | 18.367–18.367 | 1395 | - |
| actions-cache | compressible | namespace 4c | 6.1.0 | 1 | 0 | 13.493 | 13.493–13.493 | 1339 | - |
| actions-cache | random | depot 4c | 6.1.0 | 1 | 0 | 51.203 | 51.203–51.203 | 4500 | - |
| actions-cache | random | github 4c | 6.1.0 | 1 | 0 | 20.255 | 20.255–20.255 | 4500 | - |
| actions-cache | random | namespace 4c | 6.1.0 | 1 | 0 | 15.618 | 15.618–15.618 | 4317 | - |
| boringcache | compressible | depot 4c | 1.42.0 | 1 | 0 | 30.06 | 30.06–30.06 | 1399 | 0.179 |
| boringcache | compressible | github 4c | 1.42.0 | 1 | 0 | 33.962 | 33.962–33.962 | 1397 | 0.88 |
| boringcache | compressible | namespace 4c | 1.42.0 | 1 | 0 | 31.488 | 31.488–31.488 | 1349 | 0.38 |
| boringcache | random | depot 4c | 1.42.0 | 1 | 0 | 39.02 | 39.02–39.02 | 4505 | 0.194 |
| boringcache | random | github 4c | 1.42.0 | 1 | 0 | 36.96 | 36.96–36.96 | 4500 | 0.418 |
| boringcache | random | namespace 4c | 1.42.0 | 1 | 0 | 40.081 | 40.081–40.081 | 4341 | 0.416 |

## Same job

| Lane | Data | Runner | Version | Samples | Failed | Save median s | p10–p90 s | Save network MB | Restore median s | p10–p90 s | Restore network MB | Login s |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | compressible | depot 4c | 6.1.0 | 1 | 0 | 18.179 | 18.179–18.179 | 1385 | 5.877 | 5.877–5.877 | 1409 | - |
| actions-cache | compressible | github 4c | 6.1.0 | 1 | 0 | 17.771 | 17.771–17.771 | 1395 | 13.905 | 13.905–13.905 | 1387 | - |
| actions-cache | compressible | namespace 4c | 6.1.0 | 1 | 0 | 11.289 | 11.289–11.289 | 1341 | 33.173 | 33.173–33.173 | 1339 | - |
| actions-cache | random | depot 4c | 6.1.0 | 1 | 0 | 47.632 | 47.632–47.632 | 4499 | 10.637 | 10.637–10.637 | 4524 | - |
| actions-cache | random | github 4c | 6.1.0 | 1 | 0 | 17.916 | 17.916–17.916 | 4502 | 28.701 | 28.701–28.701 | 4501 | - |
| actions-cache | random | namespace 4c | 6.1.0 | 1 | 0 | 15.862 | 15.862–15.862 | 4312 | 107.08 | 107.08–107.08 | 4318 | - |
| boringcache | compressible | depot 4c | 1.42.0 | 1 | 0 | 31.954 | 31.954–31.954 | 1399 | 5.861 | 5.861–5.861 | 1408 | 0.194 |
| boringcache | compressible | github 4c | 1.42.0 | 1 | 0 | 43.677 | 43.677–43.677 | 1397 | 13.001 | 13.001–13.001 | 1398 | 0.584 |
| boringcache | compressible | namespace 4c | 1.42.0 | 1 | 0 | 32.572 | 32.572–32.572 | 1351 | 7.02 | 7.02–7.02 | 1342 | 0.43 |
| boringcache | random | depot 4c | 1.42.0 | 1 | 0 | 39.881 | 39.881–39.881 | 4505 | 8.696 | 8.696–8.696 | 4514 | 0.212 |
| boringcache | random | github 4c | 1.42.0 | 1 | 0 | 42.439 | 42.439–42.439 | 4500 | 18.726 | 18.726–18.726 | 4519 | 0.533 |
| boringcache | random | namespace 4c | 1.42.0 | 1 | 0 | 43.225 | 43.225–43.225 | 4341 | 8.24 | 8.24–8.24 | 4322 | 0.441 |
