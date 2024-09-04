Instructions:

### Running the Script
To use the script with a cron string:

```bash
ruby cron_parser.rb "*/15 0 1,15 * 1-5 /usr/bin/find"
```

### Running the Tests
To run the tests with RSpec:

```bash
rspec cron_parser_spec.rb
```

## Documentation:
- [GNU mcron Crontab File Documentation](https://www.gnu.org/software/mcron/manual/html_node/Crontab-file.html)
- [GeeksforGeeks Crontab in Linux with Examples](https://www.geeksforgeeks.org/crontab-in-linux-with-examples/)

## Testing:
- [Crontab Guru](https://crontab.guru)
- ChatGPT

## Samples:
```bash
ruby cron_parser.rb "*/15 0 1,15 * 1-5 /usr/bin/find"
ruby cron_parser.rb "0,15,25 * * * * /user/bin/find"
ruby cron_parser.rb "0-59 0-23 * * * /user/bin/find"
ruby cron_parser.rb "*/20 * * * * /user/bin/find"
ruby cron_parser.rb "10 14 * * 1 /user/bin/find"
ruby cron_parser.rb "0 0 * * * /user/bin/find"
ruby cron_parser.rb "0 0 * * 1-5 /user/bin/find"
ruby cron_parser.rb "0 0 1,15 * * /user/bin/find"
ruby cron_parser.rb "32 18 17,21,29 11 mon,wed /user/bin/find"
ruby cron_parser.rb "23 0-23/2 * * * /user/bin/find"
ruby cron_parser.rb "*/10 9-17 * * 1-5 /usr/bin/find"
ruby cron_parser.rb "*/15 * 1,29-31 * * /usr/bin/find"
ruby cron_parser.rb "0 * 1,15 * * /usr/bin/find"
ruby cron_parser.rb "*/5 12 1,15 * * /usr/bin/find"
ruby cron_parser.rb "*/10 */2 * * 1,3,5 /usr/bin/find"
ruby cron_parser.rb "0 5 1,15,28-31/1 1-12/3 * /usr/bin/find"
```

## Extra Note:
For now, I'm not implementing day of the week and month names, but it should be enought with few extra cases within the `expand` method.
