from catelab_store import CatelabStore
from unittest import TestCase
from os import unlink


class TestMetadatStore(TestCase):
    def setUp(self):
        self.store = CatelabStore('.')

    def test_can_write_arbitrary_config_key(self):
        self.store.write_config_key(
            '_UNIT_TEST_DUMMY_KEY_1', '_UNIT_TEST_DUMMY_VAL_1'
        )

    def test_can_write_and_read_arbitrary_config_key(self):
        self.store.write_config_key(
            '_UNIT_TEST_DUMMY_KEY_2', '_UNIT_TEST_DUMMY_VAL_2'
        )

        assert self.store.load_config_key('_UNIT_TEST_DUMMY_KEY_2')\
            == '_UNIT_TEST_DUMMY_VAL_2'

    def test_can_update_previously_written_config_key(self):
        self.store.write_config_key(
            '_UNIT_TEST_DUMMY_KEY_3', '_UNIT_TEST_DUMMY_VAL_3a'
        )

        assert self.store.load_config_key('_UNIT_TEST_DUMMY_KEY_3')\
            == '_UNIT_TEST_DUMMY_VAL_3a'

        self.store.write_config_key(
            '_UNIT_TEST_DUMMY_KEY_3', '_UNIT_TEST_DUMMY_VAL_3b'
        )

        assert self.store.load_config_key('_UNIT_TEST_DUMMY_KEY_3')\
            == '_UNIT_TEST_DUMMY_VAL_3b'

    def test_can_clear_all_data(self):
        self.store.write_config_key(
            '_UNIT_TEST_DUMMY_KEY_4', '_UNIT_TEST_DUMMY_VAL_4'
        )

        assert self.store.load_config_key('_UNIT_TEST_DUMMY_KEY_4')\
            == '_UNIT_TEST_DUMMY_VAL_4'
        self.store.clear()
        assert len(self.store.load_config_key('_UNIT_TEST_DUMMY_KEY_4'))\
            == 0

    def tearDown(self):
        unlink(CatelabStore._METADATA_STORE_FILENAME)  # noqa
