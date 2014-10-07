SendmailHacks -- HACKs for Sendmail
===================================

HACK 1:

maxrcpt.m4  --  Allow setting the max recipients per message based on sender address

  1. Place the maxrcpt.m4 file in your sendmail-X.Y.Z/cf/hack directory
  2. Add HACK(maxrcpt) to your .mc file
  3. Build your .cf as usual
  4. Add entries to your access_db as per the instructions in the .m4

Note: If you use the FEATURE(delay_checks), then make sure HACK(maxrcpt) comes later in the .mc file!

Note: The confMAX_RCPTS_PER_MESSAGE defined in the .mc file will be a system-wide hard limit, thus
      any RMAX: settings greater than that will be useless.  So it is best to set confMAX_RCPTS_PER_MESSAGE
      to the max you'd ever want anyone to ever have, and then use the RMAX:. setting in the access_db to
      define the runtime "default" setting.  Then you can have per-domain & per-user RMAX: settings
      which are higher than the default, but less than the hard limit.

