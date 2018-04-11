# -*- coding: utf-8 -*-
from plugin_helpers import emphasize_text
from datetime import date


TARGET_DATE = date(2018, 5, 15)
days_until = str((TARGET_DATE - date.today()).days)

# Return to evaling shell
print(
    "{icon} printf ' There are '; {days} printf 'until '; {target_date_humanized} printf '.\n'".format(
        icon=emphasize_text('blue', ' i'),
        days=emphasize_text('blue', '{days_until} days '.format(days_until=days_until)),
        target_date_humanized=emphasize_text('green', TARGET_DATE.strftime('%B %d, %Y'))
    )
)

