# SQL-Server-Learning

## 1. **Tối ưu hóa truy vấn (Query Optimization)**

### Kỹ thuật và công cụ:

* **Explain Plan** / `EXPLAIN` / `ANALYZE` trong PostgreSQL, MySQL
* **Chỉ mục (Index)**: B-Tree, Hash, Composite, Partial, Covering Index
* **Materialized View**: tăng tốc truy vấn phức tạp
* **Denormalization** trong các hệ thống cần hiệu năng cao

---

## 2. **Quản lý giao dịch (Transaction Management)**

### Các khái niệm:

* **ACID**: Atomicity, Consistency, Isolation, Durability
* **Isolation Levels**:

  * Read Uncommitted
  * Read Committed
  * Repeatable Read
  * Serializable
* **Phantom Read**, **Non-repeatable Read**, **Dirty Read**

---

## 3. **Replication và Sharding**

### Replication:

* **Master-Slave**, **Master-Master**
* **Asynchronous vs Synchronous**
* **Conflict Resolution** trong multi-master

### Sharding:

* **Horizontal Sharding (Range, Hash, Composite key)**
* **Shard Key Design**
* **Rebalancing, Resharding**

---

## 4. **Index nâng cao**

* **Partial Index**, **Expression Index** (PostgreSQL)
* **Bitmap Index**, **GiST/GIN** (đối với dữ liệu text/JSON)
* **Full-text Search Index**: `tsvector` trong PostgreSQL, `MATCH AGAINST` trong MySQL

---

## 5. **NoSQL Databases và Polyglot Persistence**

* **Document Store**: MongoDB, Couchbase
* **Key-Value Store**: Redis, DynamoDB
* **Wide Column Store**: Cassandra, HBase
* **Graph DB**: Neo4j, ArangoDB
* **Khi nào chọn SQL, khi nào chọn NoSQL**

---

## 6. **Concurrency Control**

* **Pessimistic vs Optimistic Locking**
* **Row-level vs Table-level locks**
* **MVCC (Multiversion Concurrency Control)**: được dùng trong PostgreSQL, Oracle...

---

## 7. **Stored Procedures, Triggers, và Event-driven DB**

* Viết **Stored Procedures** bằng PL/pgSQL, T-SQL, v.v.
* Sử dụng **Trigger** cho tự động hoá logic: Audit Log, Cascade Delete
* Event Notification (PostgreSQL `NOTIFY`/`LISTEN`, MongoDB Change Stream)

---

## 8. **Quản lý schema và migration**

* **Versioned Migration Tool**: Liquibase, Flyway, Alembic
* **Zero Downtime Migration**
* **Backward/Forward Compatible Changes**

---

## 9. **Quản lý dữ liệu lớn và phân tán**

* **OLTP vs OLAP**: sự khác biệt trong thiết kế schema
* **Data Warehouse**: Snowflake, Redshift, BigQuery
* **Data Lake và Lakehouse architecture**
* **Streaming DB**: Kafka + ksqlDB, Materialize

---

## 10. **Bảo mật và phân quyền (Security & Authorization)**

* **Row-level Security** (RLS)
* **Data Encryption at Rest/Transit**
* **Role-based Access Control (RBAC)** / Attribute-based (ABAC)
* **Audit Logging**
