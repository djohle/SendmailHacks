divert(-1)

dnl ALLOW SETTING A MAXIMUM RECIPIENTS BASED ON THE SENDER

dnl Original code found at: http://compgroups.net/comp.mail.sendmail/limiting-recipients-on-a-per-user-basis/1312901
dnl Much repair necessary due to line wrapping and lost tabs!
dnl Additional improvements for global default fallback & sanity checking
dnl And a further enhancement to make it compatible with FEATURE(`delay_checks')  (which must be prior to this HACK in your .mc file!)
dnl This version maintained at: https://github.com/djohle/SendmailHacks

dnl You can limit the number of recipients a sender can send to with RMAX: prefix in the access database like so:

dnl RMAX:.                    n      # Override default from .cf file with n
dnl RMAX:domain.tld           n      # Override access_db default with n for all senders in domain.tld
dnl RMAX:user@domain.tld      n      # Override all of the above with n for a specific sender

dnl The most specific value found is the one that is used

divert(0)dnl

dnl We MUST have the access database enabled...
ifdef(`_ACCESS_TABLE_', `',`
   errprint(`*** ERROR: HACK(`maxrcpt') requires FEATURE(`access_db')')
')

VERSIONID(`hack/maxrcpt.m4   Industrial Info Resources, www.industrialinfo.com')

divert(-1)

dnl NOTE: These common rules are defined as macros to reduce redundant code, and as a result anything that m4
dnl       would interpret had to be dealt with, such as a literal $1 being written as $`'1 instead

dnl header_local - Some common header stuff for the LOCAL_* sections
define(`header_local',`
LOCAL_CONFIG
# Added by `HACK(maxrcpt)' with `LOCAL_CONFIG'

# macro storage map
Kmacro macro

LOCAL_RULESETS
# Added by `HACK(maxrcpt)' with `LOCAL_RULESETS'
')

dnl init_RMax - Get the RMax value based on a series of lookups
define(`init_RMax',`
R $`'*            $: $>CanonAddr $`'1
R $`'*            $: $`'1 $(macro {RMax} $`'@ confMAX_RCPTS_PER_MESSAGE $)
R $+ <@ $+ . >       $: < $(access RMAX:. $: $) > $`'1 <@ $`'2 . >
R < $`'* > $+ <@ $+ . >    $: < $(access RMAX:$`'3 $: $`'1 $) > $`'2 <@ $`'3 . >
R < $`'* > $+ <@ $+ . >    $: < $(access RMAX:$`'2@$`'3 $: $`'1 $) > $`'2 <@ $`'3 . >
R < $+ > $+ <@ $+ . >      $: $(macro {RMax} $`'@ $`'1 $) $`'2 <@ $`'3 . >
R < > $+ <@ $+ . >      $: $`'1 <@ $`'2 . >
')

dnl init_RCurr - Unconditionally initialize RCurr
define(`init_RCurr',`R $`'*            $: $`'1 $(macro {RCurr} $`'@ 0 $)')

dnl init_once_RCurr - Initialize RCurr only if there isn't already a value defined
define(`init_once_RCurr',`
R $`'*            $: < $&{RCurr} >
R < >          $: $(macro {RCurr} $`'@ 0 $)
')

dnl sanity_check_RMax - Load the RMax value, exit ruleset if nothing useful found
define(`sanity_check_RMax',`dnl
R $`'*            $: < $&{RMax} >
R < 0 >           $`'@ ZeroRMax for $&f
R < >          $`'@ NullRMax for $&f
')

dnl increment_RCurr - Increment the recipient count by one
define(`increment_RCurr',`dnl
R $`'*            $: $(arith + $`'@ $&{RCurr} $`'@ 1 $)
R $+           $: $(macro {RCurr} $`'@ $`'1 $)
')

dnl do_max_rcpt_check - Do the actual test if max recipients has been reached, and if so reject
define(`do_max_rcpt_check',`dnl
R $`'*            $: $(arith l $`'@ $&{RMax} $`'@ $&{RCurr} $)
R TRUE            $`'#error $`'@ 5.7.1 $: "550 Too many recipients for sender: " $&f
')



dnl NOTE: This entire hack depends on a certain order of these operations
dnl That order of operations is drastically affected by FEATURE(`delay_checks')
dnl So we have two different ruleset implementations of this hack depending on
dnl whether or not that FEATURE is enabled...

divert(0)dnl

ifdef(`_DELAY_CHECKS_',`dnl ** BEGIN delay_checks COMPATIBLE VERSION

header_local
# NOTE: This is the delay_checks compatible version

SLocal_check_mail
init_RMax
sanity_check_RMax
do_max_rcpt_check

SLocal_check_rcpt
init_once_RCurr
increment_RCurr

',`dnl ** BEGIN NORMAL VERSION

header_local
# NOTE: This version is not compatible with delay_checks (if you use delay_checks then define it prior to the `HACK' in your .mc file)

SLocal_check_mail
init_RMax
init_RCurr

SLocal_check_rcpt
sanity_check_RMax
increment_RCurr
do_max_rcpt_check

')dnl ** END delay_checks compatibility variants
