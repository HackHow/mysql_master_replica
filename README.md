# **MySQL Master and Replica Setting in Amazon Linux**

### #**_You need to prepare two machine at least with MySQL installed_**

> My Master IP : _172.31.26.19_

> My Replica IP : _172.31.23.235_

## **Configure the Master Server**

### **_Step 1 : Edit MySQL config:_**

```shell
$ sudo vim /etc/my.cnf
```

- #### add three settings in my.cnf

```text
bind-address = 172.31.26.19
server-id = 1
log_bin = mysql-bin
```

### **_Step 2 : Restart MySQL service:_**

```shell
$ sudo systemctl restart mysqld
```

### **_Step 3 : Creating a replication user:_**

```shell
$ mysql -u root -p
```

```SQL
mysql> CREATE USER 'replica'@'172.31.23.235' IDENTIFIED BY 'password';
```

```SQL
mysql> GRANT REPLICATION SLAVE ON *.* TO 'replica'@'172.31.23.235';
```

- Following this, it’s good practice to run the `FLUSH PRIVILEGES` command. This will free up any memory that the server cached as a result of the preceding CREATE USER and GRANT statements:

```SQL
mysql> FLUSH PRIVILEGES;
```

### **_Step 4 : Retrieving Binary Log Coordinates from the Source:_**

- **Please note `File` and `Position`**

```SQL
mysql> SHOW MASTER STATUS\G

*************************** 1. row ***************************
             File: mysql-bin.000019
         Position: 4659
     Binlog_Do_DB:
 Binlog_Ignore_DB:
Executed_Gtid_Set:
1 row in set (0.00 sec)
```

---

## **Configure the Slave Serve**

### **_Step 1 : Edit MySQL config:_**

```shell
$ sudo vim /etc/my.cnf
```

add three settings in my.cnf

```text
bind-address = 172.31.26.19
server-id = 1
log_bin = mysql-bin
```

### **_Step 2 : Restart MySQL service:_**

```shell
$ sudo systemctl restart mysqld
```

### **_Step 3 : Starting Replication:_**

```SQL
$ mysql -u root -p
```

```SQL
mysql> STOP REPLICA;
```

- Be sure to replace source_server_ip with your **`source server’s IP`** address. Likewise, **`replica`** and **`password`** should align with the replication user you created in configure the master server Step 3; and **`mysql-bin.000019`** and **`4659`** should reflect the binary log coordinates you obtained in configure the master server Step 4

```SQL
mysql> CHANGE REPLICATION SOURCE TO
mysql> SOURCE_HOST='172.31.26.19',
mysql> SOURCE_USER='replica',
mysql> SOURCE_PASSWORD='******',
mysql> SOURCE_LOG_FILE='mysql-bin.000019',
mysql> SOURCE_LOG_POS=4069;
```

```SQL
mysql> START REPLICA;
```

- You can see details about the replica’s current state by running the following operation. The \G modifier in this command rearranges the text to make it more readable:

```SQL
mysql> SHOW REPLICA STATUS\G;

*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: 172.31.26.19
                  Source_User: replica
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: mysql-bin.000019
          Read_Source_Log_Pos: 4659
               Relay_Log_File: ip-172-31-23-235-relay-bin.000002
                Relay_Log_Pos: 916
        Relay_Source_Log_File: mysql-bin.000019
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
. . .
```

## **Testing MySQL Master Replica**

- Your replica is now replicating data from the source. Any changes you make to the source database will be reflected on the replica MySQL instance. You can test this by creating a sample table on your source database and checking whether it gets replicated successfully.

### **_Step 1 : Begin by opening up the MySQL shell on your source machine:_**

```SQL
$ mysql -u root -p
```

```SQL
mysql> CREATE DATABASE replica;
```

```SQL
mysql> use replica;

mysql> CREATE TABLE test (id INT);
Query OK, 0 rows affected (0.02 sec)

mysql> INSERT INTO test VALUES ('1');
Query OK, 1 row affected (0.00 sec)
```

```SQL
mysql> SHOW TABLES;

+-------------------+
| Tables_in_replica |
+-------------------+
| test              |
+-------------------+
```

### **_Step 2 : Begin by opening up the MySQL shell on your replica machine:_**

- After creating a table and optionally adding some sample data to it, `go back to your replica server’s MySQL shell` and select the replicated database:

```shell
$ mysql -u root -p
```

```SQL
mysql> use replica;
```

- If replication is working correctly, you’ll see the table you just added to the source listed in this command’s output:

```SQL
mysql> SHOW TABLES;

+-------------------+
| Tables_in_replica |
+-------------------+
| test              |
+-------------------+
```

- Also, if you added some sample data to the table on the source, you can check whether that data was also replicated with a query like the following:

```SQL
mysql> SELECT * FROM test;

+------+
| id   |
+------+
|    1 |
+------+
```

## **Reference**

[_How to Configure MySQL Master-Slave Replication on CentOS 7_](https://linuxize.com/post/how-to-configure-mysql-master-slave-replication-on-centos-7/)

[_How To Set Up Replication in MySQL_](https://www.digitalocean.com/community/tutorials/how-to-set-up-replication-in-mysql)
