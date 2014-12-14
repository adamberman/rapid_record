CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
);

CREATE TABLE user_lists (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  list_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES user(id)
  FOREIGN KEY(list_id) REFERENCES list(id)
);

CREATE TABLE lists (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  users (name)
VALUES
  ("Adam"), ("John");

INSERT INTO
  lists (name)
VALUES
  ("Groceries"), ("To Do");

INSERT INTO
  user_lists (user_id, list_id)
VALUES
  (1, 1), (1, 2), (2, 1), (2, 2);
