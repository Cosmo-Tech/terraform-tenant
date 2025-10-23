**Good to know about this PostgreSQL installation**

values.yaml:
* 'database: do_not_use' = just to permit installation of metrics (without a database existing, metrics can't be installed)
* 'postgres-password' is automatically detected by the chart from the given secret, no need to overwrite it


Databases are created by their own chart. The current PostgreSQL installation is just to have a working PostgreSQL (it's about having the application, it's not about having databases)