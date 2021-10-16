# USD to EUR

This is a small Swift Command Line Tool to convert USD ($) to EUR (€) at a specific date using the official exchange rate from the European Central Bank.

## Usage

```shell
usdToEur <Date yyyy-MM-dd> <amount (optional)>
```

## Examples

- Missing dates:

```shell
$ usdToEur 1999-1-1
Error: unableToFindExchangeRate
```

- The app will display the previous available date if the requested date is not available:

```shell
$ usdToEur 1999-12-25
Date: 24 Dec 1999
1 USD = 0.986 EUR
1 EUR = 1.0142 USD
```

- Invalid date:

```shell
$ usdToEur 2015-2-29
Error: Invalid date
```

- Invalid amount:

```shell
$ usdToEur 2016-2-29 aaa
Error: Invalid amount
```

- Valid date and valid amount:

```
$ usdToEur 2016-2-29 13.37
Date: 29 Feb 2016
1 USD = 0.9184 EUR
1 EUR = 1.0888 USD
13.37 USD = 12.28 EUR
13.37 EUR = 14.56 USD
```
