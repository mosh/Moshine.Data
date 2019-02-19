namespace Moshine.Data;

uses
  Newtonsoft.Json,
  System.Collections.Generic,
  System.IO,
  System.Reflection;

type
  Connections = public class

  public
    class method LoadConnections(filename:String):Dictionary<String,Connection>;
    begin

      var rootFolder := Path.GetDirectoryName(filename);
      var fullFilename := filename;

      if(String.IsNullOrEmpty(rootFolder))then
      begin
        var assemblyLocation := typeOf(Connections).Assembly.Location;
        rootFolder := Path.GetDirectoryName(assemblyLocation);
        fullFilename := Path.Combine(rootFolder,filename);
      end;

      var items := new Dictionary<String,Connection>;

      if(File.Exists(fullFilename)) then
      begin
        var json := File.ReadAllText(fullFilename);

        var list := JsonConvert.DeserializeObject<List<Connection>>(json);

        for each item in list do
        begin
          if(not String.IsNullOrEmpty(item.Certificate))then
          begin
            var folderName := Path.GetDirectoryName(item.Certificate);
            if(String.isNullOrEmpty(folderName))then
            begin
              item.Certificate := Path.Combine(rootFolder,item.Certificate);
            end;
          end;
          items.Add(item.Name,item);
        end;

      end
      else
      begin
        raise new Exception('connections file not found');
      end;
      exit items;
    end;

  end;

end.