module type JSON_decoderS = {
  type t
};

module Decoder = (JSON_decoder : JSON_decoderS) => {
  [@bs.val] [@bs.scope("JSON")]
  external decode : string => JSON_decoder.t = "parse"
}