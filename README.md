mysql-foreign-key-checker
=========================

Checks a mysql database for foreign keys pointing to missing records.


1. Create the `db.yml` file in the same directory as this script.

```
   host: localhost
   port: 3306
   username: user
   password: pass
   database: db_name
```

2. run `ruby ./find-invalid-keys.rb`
