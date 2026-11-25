[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "bronze_openaq_locations_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared bronze_openaq_locations = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "openaq"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "openaq_locations.json"]}[Content],
  #"Imported JSON" = Json.Document(#"Navigation 4", 65001),
  #"Navigation 5" = #"Imported JSON"[results],
  #"Converted to table" = Table.FromList(#"Navigation 5", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
  #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to table", "Column1", {"id", "name", "locality", "timezone", "country", "owner", "provider", "isMobile", "isMonitor", "instruments", "sensors", "coordinates", "licenses", "bounds", "distance", "datetimeFirst", "datetimeLast"}, {"id", "name", "locality", "timezone", "country", "owner", "provider", "isMobile", "isMonitor", "instruments", "sensors", "coordinates", "licenses", "bounds", "distance", "datetimeFirst", "datetimeLast"}),
  #"Expanded country" = Table.ExpandRecordColumn(#"Expanded Column1", "country", {"id", "code", "name"}, {"id.1", "code", "name.1"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded country", {{"id.1", "country_id"}, {"code", "country_code"}, {"name.1", "country_name"}}),
  #"Expanded coordinates" = Table.ExpandRecordColumn(#"Renamed columns", "coordinates", {"latitude", "longitude"}, {"latitude", "longitude"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Expanded coordinates", {{"id", Int64.Type}, {"name", type text}, {"locality", type text}, {"timezone", type text}, {"country_id", Int64.Type}, {"country_code", type text}, {"country_name", type text}, {"latitude", type number}, {"longitude", type number}, {"isMobile", type logical}, {"isMonitor", type logical}}),
  #"Expanded sensors" = Table.ExpandListColumn(#"Changed column type", "sensors"),
  #"Expanded sensors 1" = Table.ExpandRecordColumn(#"Expanded sensors", "sensors", {"id", "name", "parameter"}, {"id.1", "name.1", "parameter"}),
  #"Expanded parameter" = Table.ExpandRecordColumn(#"Expanded sensors 1", "parameter", {"id", "name", "units", "displayName"}, {"id.2", "name.2", "units", "displayName"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Expanded parameter", {{"id.1", "sensor_id"}, {"name.1", "sensor_name"}, {"id.2", "parameter_id"}, {"name.2", "parameter_name"}, {"units", "parameter_units"}, {"displayName", "parameter_display_name"}}),
  #"Expanded owner" = Table.ExpandRecordColumn(#"Renamed columns 1", "owner", {"id", "name"}, {"id.1", "name.1"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Expanded owner", {{"id.1", "owner_id"}, {"name.1", "owner_name"}}),
  #"Expanded provider" = Table.ExpandRecordColumn(#"Renamed columns 2", "provider", {"id", "name"}, {"id.1", "name.1"}),
  #"Renamed columns 3" = Table.RenameColumns(#"Expanded provider", {{"id.1", "provider_id"}, {"name.1", "provider_name"}}),
  #"Expanded instruments" = Table.ExpandListColumn(#"Renamed columns 3", "instruments"),
  #"Expanded instruments 1" = Table.ExpandRecordColumn(#"Expanded instruments", "instruments", {"id", "name"}, {"id.1", "name.1"}),
  #"Renamed columns 4" = Table.RenameColumns(#"Expanded instruments 1", {{"id.1", "instrument_id"}, {"name.1", "instrument_name"}}),
  #"Expanded licenses" = Table.ExpandListColumn(#"Renamed columns 4", "licenses"),
  #"Expanded licenses 1" = Table.ExpandRecordColumn(#"Expanded licenses", "licenses", {"id", "name", "attribution", "dateFrom", "dateTo"}, {"id.1", "name.1", "attribution", "dateFrom", "dateTo"}),
  #"Renamed columns 5" = Table.RenameColumns(#"Expanded licenses 1", {{"id.1", "license_id"}, {"name.1", "license_name"}}),
  #"Expanded attribution" = Table.ExpandRecordColumn(#"Renamed columns 5", "attribution", {"name", "url"}, {"name.1", "url"}),
  #"Renamed columns 6" = Table.RenameColumns(#"Expanded attribution", {{"name.1", "license_attribution_name"}, {"url", "license_attribution_url"}, {"dateFrom", "license_date_from"}, {"dateTo", "license_date_to"}}),
  #"Expanded bounds" = Table.ExpandListColumn(#"Renamed columns 6", "bounds"),
  #"Expanded datetimeFirst" = Table.ExpandRecordColumn(#"Expanded bounds", "datetimeFirst", {"utc", "local"}, {"utc", "local"}),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Expanded datetimeFirst", {{"owner_id", Int64.Type}, {"owner_name", type text}, {"provider_id", Int64.Type}, {"provider_name", type text}, {"instrument_id", Int64.Type}, {"instrument_name", type text}, {"sensor_id", Int64.Type}, {"sensor_name", type text}, {"parameter_id", Int64.Type}, {"parameter_name", type text}, {"parameter_units", type text}, {"parameter_display_name", type text}, {"license_id", Int64.Type}, {"license_name", type text}, {"license_attribution_name", type text}, {"license_attribution_url", type text}, {"license_date_from", type date}, {"license_date_to", type date}, {"bounds", type text}, {"distance", type number}}),
  #"Renamed columns 9" = Table.RenameColumns(#"Changed column type 1", {{"utc", "datetime_first_utc"}, {"local", "datetime_first_local"}}),
  #"Expanded datetimeLast 1" = Table.ExpandRecordColumn(#"Renamed columns 9", "datetimeLast", {"utc", "local"}, {"utc", "local"}),
  #"Renamed columns 10" = Table.RenameColumns(#"Expanded datetimeLast 1", {{"utc", "datetime_last_utc"}, {"local", "datetime_last_local"}}),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Renamed columns 10", {{"datetime_first_utc", type datetime}, {"datetime_first_local", type datetimezone}, {"datetime_last_utc", type datetime}, {"datetime_last_local", type datetimezone}})
in
  #"Changed column type 2";
shared bronze_openaq_locations_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "bronze_openaq_locations", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
