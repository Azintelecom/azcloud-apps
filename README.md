# azcloud-apps e.g azapps

Software based cluster, storage and complex
installation provided by Azintelecom IT/Dev team.

*azapps good parts*

1. Zero administration cost
2. Modularity and extensibility.
3. Reliability and simplicity.
4. Self documentation.
5. Universality.

## Getting started

First list all available apps:
```
azin apps list
```

Create galera cluster from 3 nodes and total 200GB space for database.

```
azin apps deploy --name databases/galera --size 3 --storage 200
```




