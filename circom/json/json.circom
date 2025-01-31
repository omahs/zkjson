pragma circom 2.1.5;

include "../utils/utils.circom";
include "../../node_modules/circomlib/circuits/poseidon.circom";

template JSON (size_json, size_path, size_val) {  
    signal input json[size_json];  
    signal input path[size_path];
    signal input val[size_val];
    signal output exist;
    signal output hash;
    signal ex;
    var arr_size = 10000;
    var _exists = 0;
    var _json[arr_size] = toArr(size_json, json, 0);
    var path2[arr_size] = toArr(size_path, path, 1);
    var val2[arr_size] = toArr(size_val, val, 0);
    var partial[arr_size];
    partial[0] = 4;
    var pi2 = 1;
    var i = 0;
    while(i < arr_size){ 
        var vi = 0;
        var _path[size_path * 77];
        var len = _json[i];
        i++;
        _path[0] = len;
        var pi = 1;
        for(var i2 = 0; i2 < len; i2++){
            var plen = _json[i];
            _path[pi] = plen;
            pi++;
            i++;
            var plen2 = plen;
            if(plen == 0){
                plen2 = _json[i] == 0 ? 2 : 1;
            }
            for(var i3 = 0; i3 < plen2; i3++){
                _path[pi] = _json[i];
                pi++;
                i++;
            }
        }
        var type = _json[i];
        i++;
        var _val[size_val * 77];
        _val[0] = type;
        if(type == 1){
            _val[1] = _json[i];
            i++; 
            vi = 2;
        }else if(type == 2){
            _val[1] = _json[i];
            i++;
            _val[2] = _json[i];
            i++;
            _val[3] = _json[i];
            i++;
            vi = 4;
        } else if (type == 3){
            var slen =  _json[i];
            _val[1] = slen;
            i++;
            for(var i3 = 0;i3 < slen; i3++){
                _val[i3 + 2] = _json[i];
                i++;
            }
            vi = slen + 1;
        } else {
            vi = 1;
        }
        var path_match = 1;
        var val_match = 0;
        var path_partial_match = 1;
         for(var i4 = 0; i4  < size_path * 77; i4++){
            if(_path[i4] != path2[i4 + 1]){
                path_match = 0;
                if(path2[0] > i4 && i4 != 0) path_partial_match = 0;
            }
        }
        if(path_match == 1){
            var _val_match = 1;
            for(var i5 = 0; i5  < size_val * 77; i5++){
                if(_val[i5] != val2[i5]) _val_match = 0;
            }
            if(_val_match == 1) val_match = 1;
        }else if(path_partial_match == 1){
          var path_diff = 0;
          for(var i5 = path2[1]; i5 < _path[0];i5++) path_diff++;
          partial[pi2] = path_diff;
          pi2++;
          for(var i5 = path2[0]; i5  < pi; i5++){
             partial[pi2] = _path[i5];
             pi2++;
          }
          for(var i5 = 0; i5  < vi; i5++){
             partial[pi2] = _val[i5];
             pi2++;
          }
        }
        if(path_match == 1 && val_match == 1) _exists = 1;
    }
     if(pi2 > 0){
        var val_match = 1;
        for(var i5 = 0; i5  < size_val * 77; i5++){
            if(partial[i5] != val2[i5]) val_match = 0;
        }
        if(val_match == 1) _exists = 1;
    }
    ex <-- _exists;
    exist <== ex * ex;

    component all_hash = Poseidon(16);
    component _hash[16];
    for(var i = 0; i < 16; i++){
      _hash[i] = Poseidon(16);
      for(var i2 = 0; i2 < 16; i2++){
        _hash[i].inputs[i2] <== json[i * 16 + i2];
      }
      all_hash.inputs[i] <== _hash[i].out;
    } 
    hash <== all_hash.out;
}