[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared bronze_openaq_locations = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "bronze_openaq_locations", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "openaq_daily_measurements_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "sensor_id", DestinationColumnName = "sensor_id"], [SourceColumnName = "sensor_name", DestinationColumnName = "sensor_name"], [SourceColumnName = "parameter_name", DestinationColumnName = "parameter_name"], [SourceColumnName = "parameter_units", DestinationColumnName = "parameter_units"], [SourceColumnName = "location_name", DestinationColumnName = "location_name"], [SourceColumnName = "locality", DestinationColumnName = "locality"], [SourceColumnName = "latitude", DestinationColumnName = "latitude"], [SourceColumnName = "longitude", DestinationColumnName = "longitude"], [SourceColumnName = "value", DestinationColumnName = "value"], [SourceColumnName = "period_from_utc", DestinationColumnName = "period_from_utc"], [SourceColumnName = "period_to_utc", DestinationColumnName = "period_to_utc"], [SourceColumnName = "daily_average", DestinationColumnName = "daily_average"], [SourceColumnName = "minimum", DestinationColumnName = "minimum"], [SourceColumnName = "maximum", DestinationColumnName = "maximum"], [SourceColumnName = "coverage_percent", DestinationColumnName = "coverage_percent"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared openaq_daily_measurements = let
    ApiKey = "30e5ad3e4cc57de0bf49e5429e123bb14307e35b55ab9a59db57778919c38060",

    Source = #"bronze_openaq_locations",

    // Keep only the pollutants required for the project
    FilteredSensors = Table.SelectRows(
        Source,
        each List.Contains(
            {"pm25", "no2"},
            Text.Lower(Text.From([parameter_name]))
        )
    ),

    SensorColumns = Table.SelectColumns(
        FilteredSensors,
        {
            "sensor_id",
            "sensor_name",
            "parameter_name",
            "parameter_units",
            "name",
            "locality",
            "latitude",
            "longitude"
        }
    ),

    Sensors = Table.Distinct(SensorColumns, {"sensor_id"}),

    // Retrieve all daily records for one sensor
    GetSensorData = (Sensor as record) as list =>
        let
            SensorID = Number.From(Sensor[sensor_id]),

            GetPage = (PageNumber as number) =>
                Json.Document(
                    Web.Contents(
                        "https://api.openaq.org",
                        [
                            RelativePath =
                                "v3/sensors/"
                                & Number.ToText(SensorID)
                                & "/days",

                            Query = [
                                date_from = "2025-06-01",
                                date_to = "2025-06-30",
                                limit = "1000",
                                page = Text.From(PageNumber)
                            ],

                            Headers = [
                                #"X-API-Key" = ApiKey,
                                Accept = "application/json"
                            ]
                        ]
                    )
                ),

            FirstPage = GetPage(1),

            Found = try Number.From(FirstPage[meta][found])
                    otherwise 0,

            PageCount = Number.RoundUp(Found / 1000),

            AllResults =
                if PageCount = 0 then
                    {}
                else
                    List.Combine(
                        List.Transform(
                            {1..PageCount},
                            each
                                if _ = 1 then
                                    FirstPage[results]
                                else
                                    GetPage(_)[results]
                        )
                    ),

            Records = List.Transform(
                AllResults,
                (R) => [
                    sensor_id = SensorID,
                    sensor_name = Sensor[sensor_name],
                    parameter_name = Sensor[parameter_name],
                    parameter_units = Sensor[parameter_units],
                    location_name = Sensor[name],
                    locality = Sensor[locality],
                    latitude = Sensor[latitude],
                    longitude = Sensor[longitude],
                    value = try R[value] otherwise null,
                    period_from_utc =
                        try R[datetimeFrom][utc] otherwise null,
                    period_to_utc =
                        try R[datetimeTo][utc] otherwise null,
                    daily_average =
                        try R[summary][avg] otherwise null,
                    minimum = try R[summary][min] otherwise null,
                    maximum = try R[summary][max] otherwise null,
                    coverage_percent =
                        try R[coverage][percentComplete] otherwise null
                ]
            )
        in
            Records,

    // Fetch data for every selected sensor
    AllSensorRecords = List.Combine(
        List.Transform(
            Table.ToRecords(Sensors),
            each GetSensorData(_)
        )
    ),

    Result = Table.FromRecords(AllSensorRecords),
  #"Changed column type" = Table.TransformColumnTypes(Result, {{"sensor_id", Int64.Type}, {"sensor_name", type text}, {"parameter_name", type text}, {"parameter_units", type text}, {"location_name", type text}, {"locality", type text}, {"latitude", type number}, {"longitude", type number}, {"value", type number}, {"period_from_utc", type datetime}, {"period_to_utc", type datetime}, {"daily_average", type number}, {"minimum", type number}, {"maximum", type number}, {"coverage_percent", type number}})

in
    #"Changed column type";
shared openaq_daily_measurements_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "b014008e-8cae-4da2-b22b-6e9b6b29922e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "bronze_openaq_daily_measurements", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
