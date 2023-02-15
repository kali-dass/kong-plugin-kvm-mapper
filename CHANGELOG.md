![kong-img]

Key Value Mapper Plugin Change Log
=
# v0.2.0
Fixed
- Removed the index on value field
- Reason: If values larger than 8191 byes, the index complains that it is larger than the limit set in postgres. And KVM key and value insert faults.
- Author: Kalidass Mookkaiah
- Date: 14 Jun 2022

# v0.1.0
Added
- Initial release
- Author: Kalidass Mookkaiah
- Date: 25 Jan 2022

[kong-img]: https://2tjosk2rxzc21medji3nfn1g-wpengine.netdna-ssl.com/wp-content/themes/konghq/assets/img/gradient-logo.svg
