package options.group;

class SmoothGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.get('SmoothOption'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.get('smoothhealth earlyaccess'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.get('smoothHealth'),
            'smoothHealth',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.get('EarlyAccess'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.get('smoothScore'),
            'smoothScore',
            BOOL
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.get('SecretAccess'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.get('commaSeparated'),
            'commaSeparated',
            BOOL
        );
        follow.addOption(option);
    }
}