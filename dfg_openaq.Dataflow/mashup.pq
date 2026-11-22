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
  #"Changed column type" = Table.TransformColumnTypes(#"Expanded coordinates", {{"id", Int64.Type}, {"name", type text}, {"locality", type text}, {"timezone", type text}, {"country_id", Int64.Type}, {"country_code", type text}, {"country_name", type text}, {"latitude", type number}, {"longitude", type number}, {"isMobile", type logical}, {"isMonitor", type logical}})
in
  #"Changed column type";
shared bronze_openaq_locations_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "bronze_openaq_locationsbronze_openaq_locations", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
