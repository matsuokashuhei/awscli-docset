Dash documentation for AWS CLI
=

Add [awscli-docset/awscli.docset](https://github.com/matsuokashuhei/awscli-docset/tree/master/awscli.docset) into your [Dash](https://kapeli.com/dash).

# Development

## Set up SQLite (Optional)

### Install SQLite into the container

```
apt-get update
apt-get install sqlite3
```

### Create a database

```
sqlite3 awscli.docset/Contents/Resources/docSet.dsidx
SQLite version 3.27.2 2019-02-25 16:06:06
Enter ".help" for usage hints.
sqlite> CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
sqlite> CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
```

About setting up the SQLite3, please see https://kapeli.com/docsets#dashDocset .