namespace Moshine.Data.Repositories;

uses
  Dapper,
  Npgsql.*,
  System.IO, System.Security.Cryptography.X509Certificates;

type

  PostgresRepository = public class
  private
    method GetBytesFromPEM(pemString:String; section:String):array of Byte;
    begin

      var header := String.Format('-----BEGIN {0}-----', section);
      var footer := String.Format('-----END {0}-----', section);

      var start := pemString.IndexOf(header, StringComparison.Ordinal);
      if( start < 0 )then
      begin
        exit nil;
      end;

      start := start + header.Length;
      var &end := pemString.IndexOf(footer, start, StringComparison.Ordinal) - start;

      if(&end < 0) then
      begin
        exit nil;
      end;

      exit Convert.FromBase64String( pemString.Substring( start, &end ) );
    end;

    _filename:String;
    _connectionString:String;
    _certificate:X509Certificate2;
  public

    constructor(connectionString:String) withCert(filename:String);
    begin
      _filename := filename;
      _connectionString := connectionString;

      if(not String.IsNullOrEmpty(_filename))then
      begin

        if(not File.Exists(_filename))then
        begin
          raise new Exception('cert file not found');
        end;

        var text := File.ReadAllText(filename);

        var certBuffer := GetBytesFromPEM(text,'CERTIFICATE');

        _certificate := new X509Certificate2( certBuffer );
      end;

    end;

    method BuildConnection:NpgsqlConnection;
    begin
      var connection := new NpgsqlConnection(_connectionString);
      if(not String.IsNullOrEmpty(_filename))then
      begin
        connection.ProvideClientCertificatesCallback := method (clientCerts:X509CertificateCollection); begin
            clientCerts.add(_certificate);
          end;
      end;
      exit connection;
    end;

    method ResetSequence(tableName:String;newNumber:Integer);
    begin
      //ALTER SEQUENCE "Types_Id_seq" RESTART WITH 17

      var sql := String.Format('ALTER SEQUENCE "{0}_Id_seq" RESTART WITH {1}',tableName,newNumber);

      using connection := BuildConnection do
      begin
        connection.Execute(sql);
      end;

    end;
  end;

end.