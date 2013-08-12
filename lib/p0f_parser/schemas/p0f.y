
class P0fParser
  token SRC_IP SRC_PORT DEST_IP DEST_PORT RULE KEY VALUE
  rule
  entry
    : preamble "\n" empty_value "\n" key_pairs "\n" empty_value "\n" postamble
    ;
  preamble
    : '.-[ ' SRC_IP '/' SRC_PORT ' -> ' DEST_IP '/' DEST_PORT '(' RULE ') ]-'
    ;
  postamble
    : '`----'
    ;
  empty_value
    : '|'
    ;
  key_pair
    : '| ' KEY spaces '=' spaces VALUE
    ;
  key_pairs
    : key_pair
    | key_pairs "\n" key_pair
    ;
  spaces
    : ' '
    | spaces ' '
    ;
end
