def ports:
   if .IpProtocol == "-1"
   then {FromPort:"ALLPORTS", ToPort:"ALLPORTS", IpProtocol:"ALLPROTO"}
   else {FromPort, ToPort, IpProtocol}
   end
;

def tabella($g; $p; $dir; $ip):
    [ $g.GroupId, $g.GroupName, $g.Description, $g.VpcId, $dir, $ip,
      $p.FromPort, $p.ToPort, $p.IpProtocol ]
;

def creatab:
      .SecurityGroups[]
    | { GroupId, GroupName, Description, VpcId } as $g
    | (
          .IpPermissions[]
        | ports as $p
        | ( .IpRanges[]         | tabella($g; $p; "INBOUND"; .CidrIp) ),
          ( .UserIdGroupPairs[] | tabella($g; $p; "INBOUND"; .GroupId) )
      ),
      (
          .IpPermissionsEgress[]
        | ports as $p
        | ( .IpRanges[]         | tabella($g; $p; "OUTBOUND"; .CidrIp) ),
          ( .UserIdGroupPairs[] | tabella($g; $p; "OUTBOUND"; .GroupId) )
      )
;

  creatab
| map(tostring)
| join("|")