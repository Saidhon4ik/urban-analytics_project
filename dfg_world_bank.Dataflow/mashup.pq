[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "NY GDP MKTP CD_full json_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"NY GDP MKTP CD_full json" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "world_bank"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "NY.GDP.MKTP.CD_full.json"]}[Content],
  #"Imported JSON" = Json.Document(#"Navigation 4"),
  #"Navigation 5" = #"Imported JSON"{1},
  #"Converted to table" = Table.FromList(#"Navigation 5", Splitter.SplitByNothing(), null, null, ExtraValues.Error),
  #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to table", "Column1", {"indicator", "country", "countryiso3code", "date", "value", "unit", "obs_status", "decimal"}, {"indicator", "country", "countryiso3code", "date", "value", "unit", "obs_status", "decimal"}),
  #"Expanded country" = Table.ExpandRecordColumn(#"Expanded Column1", "country", {"id", "value"}, {"id", "value.1"}),
  #"Expanded indicator" = Table.ExpandRecordColumn(#"Expanded country", "indicator", {"id", "value"}, {"id.1", "value.2"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded indicator", {{"id.1", "indicator_id"}, {"value.2", "indicator_name"}, {"id", "country_id"}, {"value.1", "country_name"}}),
  #"Changed column type" = Table.TransformColumnTypes(#"Renamed columns", {{"indicator_id", type text}, {"indicator_name", type text}, {"country_id", type text}, {"country_name", type text}, {"countryiso3code", type text}, {"date", Int64.Type}, {"value", type number}, {"unit", type text}, {"obs_status", type text}, {"decimal", Int64.Type}})
in
  #"Changed column type";
shared #"NY GDP MKTP CD_full json_DataDestination" = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "NY GDP MKTP CD_full json", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
