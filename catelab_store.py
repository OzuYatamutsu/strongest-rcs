from sqlite3 import connect, Row
from os.path import join


class CatelabStore:
    _METADATA_STORE_FILENAME = 'catelab_metadata.sqlite3'
    __KEY_TABLE = 'metadata'

    def __init__(self, base_config_dir: str):
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

    def get_last_update_utime(self) -> int:
        return self.load_config_key('LAST_UPDATE_UTIME')

    def get_catelab_source_dir(self) -> str:
        return self.load_config_key('SOURCE_DIR')

    def write_config_key(self, key: str, value: str) -> str:
        cursor = self.conn.cursor()
        cursor.execute(
            f"INSERT OR REPLACE INTO {CatelabStore.__KEY_TABLE}(key, value) "
            "VALUES (?, ?)", (key, value)
        )

        self.conn.commit()

    def load_config_key(self, key: str) -> str:
        cursor = self.conn.cursor()
        cursor.execute(
            f"SELECT value FROM {CatelabStore.__KEY_TABLE} "
            "WHERE key = ?", (key,)
        )

        result = cursor.fetchone() or {}
        result = dict(result)

        if not result:
            return ""
        return result['value']

    def clear(self) -> None:
        cursor = self.conn.cursor()
        cursor.execute(
            f"DELETE FROM {CatelabStore.__KEY_TABLE}"
        )

        self.conn.commit()
