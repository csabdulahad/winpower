Set-Location 'c:/winpower';



. 'lib/func';
. 'lib/Paramize';

$command = @{
    winfi = @(
    "Shows wifi profiles and their passwords. It is one of the critical options
that WinPower provides. So it is password protected. It uses NETSH WLAN
command behind the scene. It's name is mixture of two words: WinPower & Wifi."

    "Command Syntax:
    winfi
    winfi [-list]
    winfi [profile]
    winfi [profile] [key]
    winfi [profile] [key] [copy]",

    "Flags:
    -list
    Lists the name of all available wifi profiles",

    "Args:
    #1 -profile or -p [optional]
    Valid options are: *, ANY AVAILABLE PROFILE NAME.
    When specified, it shows the key for the profile. When omitted, it
    lists all the profiles. When key argument is set ""n"" (no), it
    behaves flag -list.

    #2 -key or -k [optional]
    Valid options are: y, n.
    When set to ""y"" (yes), the password is shown in clear text. Default
    value is ""n"" (no). The password is shown in cryptic way.

    #3 -copy or -c [optional]
    Valid options are: y, n.
    When it is set ""y"" (yes), the password is copied to the clipboard.
    Default is ""n"" (no). This argument has no effect when -profile
    argument is set to *."
    )

    wdoc = @(
    "The doctor who validates WP installation and provides troubleshoot. When
there is any problem with WP installation, run this command to fix.",

    "Command Syntax:
    wdoc",

    $null,
    $null
    )

    ip = @(
    "Displays local or public ip address to the console. IP address can be
copied to the clipboard by using option -c. It uses ipify free web service
to discover the public IP address. For local IP, it just tries to calculate
the IP by searching for WiFi profile through registered networks of the
computer.",

    "Command Syntax:
    ip
    ip [type]
    ip [type] [copy]",

    $null,

    "Args:
    #1 -type or -t [Optional]
    Specifies which IP address to display. By default, it shows the public IP
    address. Options are: public, local.

    #2 -copy or -c [Optional]
    When this argument is passed with value ""y"", it copies the specified IP
    address to the clipboard. Options are: y, n.
    y = yes, n = no"
    )

    wp = @(
    "The main command of the WinPower(WP). All the commands go through this wp.
If performs many checks, syntax validations, setting environment etc.",

    "Command Syntax:
    wp
    wp [-i | -v]
    wp [args...]",

    "Flags:
    -i
    Re-run the winpower script installer. It performs all the installtion steps again.

    -v
    Returns the installed version of WinPower.",

    "Args:
    #1 args... [Optional]
    Executes a specific command with arguments if any passed in. Note that it doesn't
    have a '-' in syntax to signify that WP always takes in any number of argumnetns.
    Arguments can be command name along with any number of arguments need to be passed
    to that command. For example:
    wp ox -d"
    )

    whelp = @(
    "Shows information about WinPower commands. Very helpful command to learn.",

    "Command syntax:
    whelp
    whelp [-list]
    whelp [command]
    whelp [command] [topic]",

    "Flags:
    -list
    Lists all availabe WinPower commands with single line description.",

    "Args:
    #1 -command or -cmd [Optional]
    Possible values are: *, ANY WP COMMAND.
    Shows information about a specific command. If not specified, then lists all
    the commands.

    #2 -topic or -t [Optional]
    Value must be one of these: *, des, syntax, flags, args
    Filters specific section of a command. If not specified, then shows all parts
    of the specified command."
    )

    piyon = @(
    #info
    "Adds a specified path to the system level environment variable (EV) ""Path"".
This command was named piyon, a bangla word which means the bearer as
piyon takes the path and adds to the EV.",

    #command syntax
    "Command Sytax:
    piyon [path]
    piyon [-r] {path}",

    # flags
    "Flags:
    -r
    Removes the specified path. The path comes after the flag -r
    Path can't be empty/null
    Example: piyon -r ""c:/a path to folder""",

    # args
    "Args:
    #1 -path or -p [Optional]
    The path you want to add to the Environment Variable (EV).
    If no path is given then piyon adds the current directory to the variable."
    )

    ox = @(
    "Opens specified path in file explorer. OX stands for Open in Explorer."

    "Command Syntax:
    ox [-me | -d | -dl]
    ox [path]",

    "Flags:
    -me
    Opens the current user folder.

    -d
    Opens the desktop folder.

    -dl
    Opens user's download folder.",

    "Args:
    #1 -path or -p [Optional]
    Any path that you want to open in explorer. If no path is specified, it
    then opens the current directory."
    )
}

$topicIndex = @{
    des = 0
    syntax = 1
    flags = 2
    args = 3
}

function listAllCmd {
    # count the empty spaces to put
    $space = 0;
    foreach($cmd in $command.GetEnumerator()) {
        $count = $cmd.name.Length;
        if ($count -gt $space) {
            $space = $count + 6;
        }
    }

    foreach($cmd in $command.GetEnumerator()) {
        $name = $cmd.name;
        $spaceDiff = " " * ($space - $name.Length);
        HmWrite "&#x26A1; " Yellow $false;
        Write-Host "$name$spaceDiff" -NoNewline -ForegroundColor Cyan;

        $des = $cmd.value[0];
        Write-Host "$($des.Split('.')[0].Trim()).";
    }
}

function listCmd {
    param([string]$name, [string]$topic)

    foreach($cmd in $command.GetEnumerator()) {

        $key = if ($name -eq '*') { $cmd.name } else { $name };
        if (-not $command.ContainsKey($key)) { throw 'No help for unknown command'; }

        $data = $command[$key];
        for ($i = 0; $i -lt $data.Length; $i++) {
            $tIndex = if ($topic -eq '*') { $i } else { $topicIndex[$topic] }
            if ($null -eq $tIndex) { throw 'Unknow topic was requested'; }

            # show the command name if all the topics are request
            if ($topic -eq '*' -and $i -eq 0) {
                HmWrite "&#x26A1; " Yellow $false;
                Write-Host $key -ForegroundColor Cyan;
            }

            $str = $data[$tIndex];
            if ($null -ne $str) {
                Write-Host "$str`n";
            } elseif ($topic -ne '*') {
                Highlight "$key doesn't have info about: $topic";
            }

            if ($topic -ne '*') { break; }
        }

        # asked for specific command so stop here!
        if ($name -ne '*') { break; }
    }
}

try {
    $pm = [Paramize]::new();

    $pm.cmd('list');

    $pm.add(@{
        lName = 'command'
        sName = 'cmd'
        def = '*'
    });

    $pm.add(@{
        lName = 'topic'
        sName = 't'
        def = '*'
    });

    $pm.validate($args);

    if ($pm.hitCmd('list')){
        listAllCmd;
        exit;
    }

    $c = $pm.hitOrDef('command');
    $topic = $pm.hitOrDef('topic');

    listCmd $c $topic;

} catch {
    Err;
}