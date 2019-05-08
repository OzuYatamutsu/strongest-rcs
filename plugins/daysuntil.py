# -*- coding: utf-8 -*-
from datetime import date
TARGET_DATE = date(2019, 7, 4)


def main():
    global TARGET_DATE
    days_until = (TARGET_DATE - date.today()).days

    result = (
        f" <blue>i<reset> There {'are' if days_until != 1 else 'is'} "
        f"<blue>{str(days_until) if days_until >= 0 else '0'} "
        f"{'days' if days_until != 1 else 'day'}<reset> "
        f"until <green>{TARGET_DATE.strftime('%B %d, %Y')}."
    )

    print(result)


if __name__ == '__main__':
    main()
