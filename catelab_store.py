from sqlite3 import connect, Row
from os.path import join
from os import environ
from sys import argv


class CatelabStore:
    _METADATA_STORE_FILENAME = 'catelab_metadata.sqlite3'
    __KEY_TABLE = 'metadata'

    def __init__(self, base_config_dir=None):
        base_config_dir = base_config_dir or environ['CATELAB_METADATA_DIR']
        self.conn = connect(join(
            base_config_dir, CatelabStore._METADATA_STORE_FILENAME
        ))
        self.conn.row_factory = Row
        self.conn.execute(
            "CREATE TABLE IF NOT EXISTS metadata("
            "key TEXT PRIMARY KEY, value TEXT"
            ")"
        )
        self.conn.commit()

    def write_config_key(self, key: str, value: str) -> str:
        cursor = self.conn.cursor()
        cursor.execute(
            f"INSERT OR REPLACE INTO {CatelabStore.__KEY_TABLE}(key, value) "
            "VALUES (?, ?)", (key.strip(), value.strip())
        )

        self.conn.commit()

    def load_config_key(self, key: str) -> str:
        cursor = self.conn.cursor()
        cursor.execute(
            f"SELECT value FROM {CatelabStore.__KEY_TABLE} "
            "WHERE key = ?", (key.strip(),)
        )

        result = cursor.fetchone() or {}
        result = dict(result)

        if not result:
            return ""
        return result['value']

    def dump(self) -> dict:
        cursor = self.conn.cursor()
        cursor.execute(
            f"SELECT key, value FROM {CatelabStore.__KEY_TABLE}"
        )

        result = cursor.fetchall()
        if not result:
            return {}

        return {
            row['key']: row['value']
            for row in [dict(row) for row in result]
        }

    def clear(self) -> None:
        cursor = self.conn.cursor()
        cursor.execute(
            f"DELETE FROM {CatelabStore.__KEY_TABLE}"
        )

        self.conn.commit()


if __name__ == '__main__':
    if len(argv) == 1:
        # List all keys and values
        result = '\n'.join([
            f"{key} = {value}"
            for key, value in CatelabStore(
                base_config_dir=environ['CATELAB_METADATA_DIR']
            ).dump().items()
        ])
    elif len(argv) == 2:
        # Doing a read
        result = CatelabStore(
            base_config_dir=environ['CATELAB_METADATA_DIR']
        ).load_config_key(key=argv[1])
    elif len(argv) == 3:
        # Doing a write
        CatelabStore(
            base_config_dir=environ['CATELAB_METADATA_DIR']
        ).write_config_key(key=argv[1], value=argv[2])
        result = ''
    else:
        print("Pass 1, 2, or 3 arguments.")
        exit(-1)
    print(result)
