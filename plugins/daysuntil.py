# -*- coding: utf-8 -*-
from datetime import date

TARGET_DATE = date(2018, 6, 30)
days_until = (TARGET_DATE - date.today()).days

result = " <blue>i<reset> There {are_or_is} <blue>{days} {days_or_day}<reset> until <green>{target_date_humanized}.".format(
    are_or_is='are' if days_until != 1 else 'is',
    days=str(days_until) if days_until >= 0 else '0',
    days_or_day='days' if days_until != 1 else 'day',
    target_date_humanized=TARGET_DATE.strftime('%B %d, %Y')
)

print(result)

