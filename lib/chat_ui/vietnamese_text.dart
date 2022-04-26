extension NumberParsing on String {
  String removeAccents(){
    List<String> chars = toLowerCase().split("");
    String a = "áàảạãăắằẳặẵâấầẩẫậ";
    String d = "đ";
    String e = "éèẻẽẹêếềểễệ";
    String i = "íìỉĩị";
    String o = "óòỏõọôốồổỗộơớờởỡợ";
    String u = "úùủũụưứừửữự";
    String y = "ýỳỷỹỵ";
    String result = "";
    for (var element in chars) {
      if(a.contains(element)) {
        element = "a";
      } else if(d.contains(element)){
        element = "d";
      }
      else if(e.contains(element)){
        element = "e";
      }
      else if(i.contains(element)){
        element = "i";
      }
      else if(o.contains(element)){
        element = "o";
      }
      else if(u.contains(element)){
        element = "u";
      }
      else if(y.contains(element)){
        element = "y";
      }
      result += element;
    }
    return result;
  }
}