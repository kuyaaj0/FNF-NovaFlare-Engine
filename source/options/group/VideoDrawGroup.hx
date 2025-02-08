package options.group;

class VideoDrawGroup
{
    static public function add(follow:OptionBG) {
        var option:Option = new Option(
            Language.get('VideoDrawOption'),
            TITLE
        );
        follow.addOption(option);

        var reset:ResetRect = new ResetRect(450, 20, follow);
        follow.add(reset);

        ///////////////////////////////

        var option:Option = new Option(
            Language.get('Performance'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.get('drawDistanceModifier'),
            'drawDistanceModifier',
            FLOAT,
            0,
            1,
            1
        );
        follow.addOption(option);

        ///////////////////////////////

        var option:Option = new Option(
            Language.get('Draw_shader_idk'),
            TEXT
        );
        follow.addOption(option);

        var option:Option = new Option(
            Language.get('holdSubdivs'),
            'holdSubdivs',
            INT,
            0,
            6
        );
        follow.addOption(option);
    }
}