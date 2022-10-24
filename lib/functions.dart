String tf2yn(bool tf) {
  return tf ? "yes" : "no";
}

Map<String, dynamic> makeSessionPayloads(Map<String, dynamic> session) {
  final protocol = session["protocols"][0];
  final urls = session["urls"];
  bool isWellKnownPort = true;
  bool isSsl = true;
  for (final url in urls) {
    isWellKnownPort = url["isWellKnownPort"];
    isSsl = url["isSsl"];
    break;
  }
  final payloads = {};
  payloads["recipe_id"] = session["recipeId"];
  payloads["content_id"] = session["contentId"];
  payloads["content_type"] = "movie";
  payloads["content_src_id_sets"] = [
    {
      "content_src_ids": [
        {
          "src_id_to_mux": {
            "video_src_ids": session["videos"],
            "audio_src_ids": session["audios"]
          }
        },
      ]
    }
  ];
  payloads["timing_constraint"] = "unlimited";
  payloads["keep_method"] = {
    "heartbeat": {"lifetime": session["heartbeatLifetime"]}
  };
  payloads["protocol"] = {
    "name": protocol,
    "parameters": {
      "http_parameters": {
        "parameters": {
          "hls_parameters": {
            "use_well_known_port": tf2yn(isWellKnownPort),
            "use_ssl": tf2yn(isSsl),
            "transfer_preset": "",
            "segment_duration": 6000,
          }
        }
      }
    }
  };
  payloads["content_uri"] = "";
  payloads["session_operation_auth"] = {
    "session_operation_auth_by_signature": {
      "token": session["token"],
      "signature": session["signature"]
    }
  };
  payloads["content_auth"] = {
    "auth_type": session["authTypes"][protocol],
    "content_key_timeout": session["contentKeyTimeout"],
    "service_id": "nicovideo",
    "service_user_id": session["serviceUserId"]
  };
  payloads["client_info"] = {
    "player_id": session["playerId"],
  };
  payloads["priority"] = session["priority"];
  return {"session": payloads};
}
