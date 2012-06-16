class packages::gdash {
  include packages::aptget

  package { gdash:
  	    provider => gem,
	    ensure   => present,
  }

	# Need Unicorn
	# Need a lot of other junk :)
}
