SendmailHacks -- HACKs for Sendmail
===================================

Allow setting the max recipients per message based on sender address
  1. Place the maxrcpt.m4 file in your sendmail-X.Y.Z/cf/hack directory
  2. Add HACK(maxrcpt) to your .mc file
  3. Build your .cf as usual
  4. Add entries to your access_db as per the instructions in the .m4

Note: If you use the FEATURE(delay_checks), then make sure HACK(maxrcpt) comes later in the .mc file!
