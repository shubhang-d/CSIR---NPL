

List<double> stringFormatter(String str){
  var list = str.split(';');
  var list2 = list[0].split('V');
  var volt = 0.0;
  if(list2[0].trim().isEmpty){
    volt = 0.0;
  }else{
    volt = double.parse(list2[0].trim());  
  }
  
  var list3 = [];
  if(list.length >1){
    list3 = list[1].split('G');
  }else{
    list3 = list[0].split('G');
  }
  var gauss = 0.0;
  if(list3[0].trim().isEmpty){
    gauss = 0.0;
  }else{
    gauss = double.parse(list3[0].trim());  
  }
  return [volt, gauss];
}