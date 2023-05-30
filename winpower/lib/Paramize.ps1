
<#
# This calss can help validate command line param/arugment. It can
# all a param to be optional or rquired. It can also perform empty
# value check on parameter value.
#
#       $pz = [Paramize]::new();
#
#       # param that is requried and value can't be empty
#       $px.add(
#           lName = 'path' # long name
#           sName = 'p'   # short name
#       );
#
#        # add special single cmd command like -i, -v
#        $px.cmd('i');
#
#       # you can check it was hit or even can extract its argument
#       $px.hitCmd('i');                    # automatically adds extra 'cls
#       $px.hitCmdArg('i');
#
#
#       # param that is optional and value can be empty
#       $px.add(
#           lName       = 'path2'           # long name
#           sName       = 'p2'              # short name
#           def         = 'value'           # default value
#           canEmpty    = 1                 # can be any value; falg is counted
#       );
#
#       $pz.validate($arg);                 # can provide any array; default is $args variable
#
# You can calculate whether any param were passed by the follwoing method:
#       $pz.noArg();                        # returns true if any params were validated
#
# Validated param value can be extracted using the following method:
#       $pz.hitOrDef('path');               # returns either user provided value on hit; otherwise default one
#                                           # full name must be used to fetch the value. '-' auto provided.
 #>

class Paramize {

    # arguments buffer
    [string[]] $_argBuffer;

    # flag to check for positional arguments
    [boolean] $_checkPos = $true;

    # zero arg
    [boolean] $_zeroArg = $false;

    # array holds the position of each param
    [string[]] $_posParam;

    # map holds the relation between long & short name of each param
    [PSCustomObject] $_transTable;

    # param meta object
    [PSCustomObject] $_paramMeta;

    # this holds actual value provided by the user for both the default and requried params
    [PSCustomObject] $_paramVal;

    # list holds the parmaters which must be provided by the user
    [PSCustomObject] $_reqParam;


    # contains the special single command params like -i, -v etc
    [string[]] $_cmdList;

    # tracks which cmd was hit
    [string] $_cmdHit;

    Paramize () {
        $this._transTable = @{};
        $this._paramVal = @{};
        $this._paramMeta = @{};
        $this._reqParam = New-Object System.Collections.ArrayList; # resizeable array list
        $this._cmdList = @();
    }

    [void] disablePosCheck() {
        $this._checkPos = $false;
    }

    [void] add([PSCustomObject] $obj) {
        # first add - to the long and short name
        if (-not $obj.lName.StartsWith('-')) {
            $obj.lName = '-' + $obj.lName;
        }

        if (-not $obj.sName.StartsWith('-')) {
            $obj.sName = '-' + $obj.sName;
        }

        $lName = $obj.lName;

        # if it is required param then add it the required array
        if (-not $obj.ContainsKey('def')) {
            $this._reqParam.Add($lName);
        }

        # add the param to the translate table
        $this._transTable.$($lName) = $obj.sName;

        # also add to the positional param array
        $this._posParam += $lName;

        # initiate this parameter in the paramVal variable
        $this._paramVal.$($lName) = $null;

        # delete the long & short name from the param object
        $obj.Remove('lName');
        $obj.Remove('sName');

        $this._paramMeta.$($lName) = $obj;
    }

    # add special single command param like -i, -v
    [void] cmd([string] $cmd) {
        if (-not $cmd.StartsWith('-')) { $cmd = "-$cmd"; }
        $this._cmdList += $cmd;
    }

    # returns whether any specific special listed cmd was found or not
    [boolean] hitCmd([string] $cmd) {
        if (-not $cmd.StartsWith('-')) { $cmd = "-$cmd"; }
        return $this._cmdHit -eq $cmd;
    }

    # returns the next valu in arguments if the specific cmd was hit
    [object] hitCmdArg([string] $cmd) {
        if (-not $this.hitCmd($cmd)) { return $null; }
        return $this._argBuffer[1];
    }

    # returns whether a param was provided by the user
    [boolean] hit([string] $key) {
        $key = $this._hasParam($key);
        return $null -ne $this._paramVal.$($key);
    }

    [object] hitVal([string] $key) {
        if (-not $this.hit($key)) { return $null; }
        return $this._paramVal.$($this._hasParam($key));
    }

    # returns whether a param was provided by the user and matches with a specific value
    [boolean] hitNEqual([string] $key, [string] $val) {
        $key = $this._hasParam($key);
        if (-not $this._paramVal.ContainsKey($key)) { return $false; }
        return $this._paramVal.$($key) -eq $val;
    }

    # for a parameter it gives the user inputed value; default one otherwise
    [object] hitOrDef([string] $param) {

        $param = $this._hasParam($param);

        if (-not $this._paramVal.ContainsKey($param)) {
            throw 'Value for unknown param ' + $param + ' requested';
        }

        $val = $this._paramVal.$($param);
        if ($null -eq $val) {
            $val = $this._valParamMeta('def', $param);
        }
        return $val;
    }

    # this method can tell whether any argument provided by user and validated
    [boolean] noArg() { return $this._zeroArg; }

    [string] _fullMsg([string] $param) {
        $param = $this._hasParam($param);
        if ($this._paramMeta.$($param).ContainsKey('msg')) {
            return $this._paramMeta.$($param).msg;
        }
        return 'No infomration available';
    }

    # tells whether the key exists in param meta
    [boolean] _keyInParamMeta([string] $key, [string] $paramName) {
        return $this._paramMeta.$($paramName).ContainsKey($key);
    }

    # gets the value for a key for a specified param
    [string] _valParamMeta([string] $key, [string] $paramName) {
        return $this._paramMeta.$($paramName).$($key);
    }

     # for a param, calculate long name regadless of long/short name provided; removes confusions
    [object] _hasParam([string] $param) {
        $param = if ($param.StartsWith('-')) { $param; } else { "-$param" }
        foreach ($i in $this._transTable.GetEnumerator()) {
            if ($param -ieq $i.Name -or $param -ieq $i.Value) {
                return $i.Name;
            }
        }
        return $null;
    }

    # this method validates arguments
    [void] validate([Object[]] $arg) {

        $this._argBuffer = $arg;

        $this._zeroArg = $this._argBuffer -eq $null -or $this._argBuffer.Length -eq 0;

        # cast all args into string type and also look for special cmd command
        for ($i = 0; $i -lt $this._argBuffer.Length; $i++) {
            # to string then save it
            $val = [string] $this._argBuffer[$i];
            $this._argBuffer[$i] = $val;

            # check for cmd!
            if ($this._cmdList.Contains($val)) {
                $this._cmdHit = $val;
                return;
            }
        }


        $namedArg = $this._argBuffer.Length -gt 0 -and $this._argBuffer[0].StartsWith('-');
        if ($namedArg) {
            # Named arguments were passed
            $this._nameArg($this._argBuffer);
        } elseif ($this._checkPos) {
            # Positional this._argBufferumetns were passed
            $this._posArg($this._argBuffer);
        }
    }

    [void] _nameArg([string[]] $arg) {
        $skipNext = $false;

        for ($i = 0; $i -lt $arg.Length; $i++) {

            # do we get a - marked param? which has default value and the next one is another - marked param?
            # then we continue next iteraion as def is enough for that.
            if ($skipNext) {
                $skipNext = $false;
                continue;
            }

            # make sure we have valid param to deal with
            $param = $this._hasParam($arg[$i]);
            if ($null -eq $param) {
                Throw "Invalid param: " + $arg[$i];
            }

            # first learn if def can be provided
            $hasDefVal = $this._keyInParamMeta('def', $param);

            # get the next value
            $nextVal = $arg[$i+1];
            $noDefNoProvided = (-not $hasDefVal) -and ($null -eq $nextVal -or $nextVal.StartsWith('-'));
            if ($noDefNoProvided) {
                throw "No value provided for: $($arg[$i])`n$($arg[$i]): " + $this._fullMsg($arg[$i]);
            }

            # if value is provided then set it & control the skip flag properly
            if ($null -ne $nextVal -and -not $nextVal.StartsWith('-')) {
                $skipNext = $true;

                # now check whether the provided value can be empty or not
                if (-not $this._keyInParamMeta('canEmpty', $param) -and $nextVal.Trim() -eq '') {
                    Throw "Value can't be empty for: " + $arg[$i];
                }

                $this._paramVal.$($param) = $nextVal;
            } else {
                # here the default value will be acquired by hitOrDef() method; no need to set def value
                $skipNext = $false;
            }

            # remove if we have done with a required one so count requried params
            if ($this._reqParam.Contains($param)) {
                $this._reqParam.Remove($param);
            }
        }

        <#
        # No matter what params were passed-in, we must get the requried ones in place
        #>
        if ($this._reqParam.Length -gt 0) {
            $param = 'Missing param: ';
            foreach ($i in $this._reqParam) {
                $param += "$i, ";
            }
            $param = $param.TrimEnd(', ');

            # add detailed message
            foreach($i in $this._reqParam) {
                $param += "`n$i`: " + $this._fullMsg($i);
            }

            throw $param;
        }
    }

    [void] _posArg([string[]] $arg) {
        # first validate that we have not got more than necessary
        if ($arg.Length -gt $this._posParam.Length) {
            throw 'Argument expected ' + $this._posParam.Length + ', given ' + $arg.Length;
        }

        for ($i = 0; $i -lt $this._posParam.Count; $i++) {

            $posParam = $this._posParam[$i];

            $val = $arg[$i];
            $hasDefVal = $this._paramMeta.$($posParam).ContainsKey('def');

            if ($null -eq $val -and -not $hasDefVal) {
                throw 'Value is missing for param: ' + $posParam;
            }

            # now check whether the provided value can be empty or not

            # whether it was marked that it can be empty
            $emptinessFlag = $this._keyInParamMeta('canEmpty', $posParam);

            $nullOrTrimEmpty = $null -eq $val -or $val.Trim() -eq '';

            if (-not $hasDefVal -and -not $emptinessFlag -and $nullOrTrimEmpty) {
                Throw "Value can't be empty for arg #$($i+1): " + $posParam;
            }

            $this._paramVal.$($posParam) = $val;
        }
    }

}