defmodule TdSe.Search.QueryTest do
  use ExUnit.Case

  alias TdSe.Search.Query

  @structures Application.compile_env(:td_se, :index_aliases)[:structures]
  @concepts Application.compile_env(:td_se, :index_aliases)[:concepts]

  @indices %{
    @concepts => "concepts_idx",
    @structures => "structures_idx"
  }

  describe "build_query/2" do
    test "when all permissions have scope all" do
      assert Query.build_query(
               %{
                 "manage_confidential_business_concepts" => :all,
                 "manage_confidential_structures" => :all,
                 "view_data_structure" => :all,
                 "view_published_business_concepts" => :all
               },
               @indices
             ) == %{
               bool: %{
                 minimum_should_match: 1,
                 should: [
                   %{
                     bool: %{
                       filter: [
                         %{term: %{"_index" => "concepts_idx"}},
                         %{term: %{"status" => "published"}}
                       ]
                     }
                   },
                   %{
                     bool: %{
                       filter: [%{term: %{"_index" => "structures_idx"}}],
                       must_not: %{exists: %{field: "deleted_at"}}
                     }
                   }
                 ]
               }
             }
    end

    test "when all permissions have scope none" do
      assert Query.build_query(
               %{
                 "manage_confidential_business_concepts" => :none,
                 "manage_confidential_structures" => :none,
                 "view_data_structure" => :none,
                 "view_published_business_concepts" => :none
               },
               @indices
             ) == %{match_none: %{}}
    end

    test "when no permissions are present" do
      assert Query.build_query(%{}, @indices) == %{match_none: %{}}
      assert Query.build_query(%{"foo" => [1]}, @indices) == %{match_none: %{}}
    end

    test "concepts permissions" do
      assert Query.build_query(%{"view_published_business_concepts" => :all}, @indices) ==
               %{
                 bool: %{
                   filter: [
                     %{term: %{"_index" => "concepts_idx"}},
                     %{term: %{"status" => "published"}}
                   ],
                   must_not: %{term: %{"confidential.raw" => true}}
                 }
               }

      assert Query.build_query(
               %{
                 "view_published_business_concepts" => :all,
                 "manage_confidential_business_concepts" => :all
               },
               @indices
             ) ==
               %{
                 bool: %{
                   filter: [
                     %{term: %{"_index" => "concepts_idx"}},
                     %{term: %{"status" => "published"}}
                   ]
                 }
               }

      assert Query.build_query(%{"view_published_business_concepts" => [1]}, @indices) == %{
               bool: %{
                 filter: [
                   %{term: %{"domain_ids" => 1}},
                   %{term: %{"_index" => "concepts_idx"}},
                   %{term: %{"status" => "published"}}
                 ],
                 must_not: %{term: %{"confidential.raw" => true}}
               }
             }

      assert Query.build_query(
               %{
                 "view_published_business_concepts" => [1],
                 "manage_confidential_business_concepts" => :all
               },
               @indices
             ) == %{
               bool: %{
                 filter: [
                   %{term: %{"domain_ids" => 1}},
                   %{term: %{"_index" => "concepts_idx"}},
                   %{term: %{"status" => "published"}}
                 ]
               }
             }

      assert Query.build_query(
               %{
                 "view_published_business_concepts" => [1],
                 "manage_confidential_business_concepts" => [2, 3]
               },
               @indices
             ) == %{
               bool: %{
                 filter: [
                   %{term: %{"domain_ids" => 1}},
                   %{
                     bool: %{
                       should: [
                         %{terms: %{"domain_ids" => [2, 3]}},
                         %{term: %{"confidential.raw" => false}}
                       ]
                     }
                   },
                   %{term: %{"_index" => "concepts_idx"}},
                   %{term: %{"status" => "published"}}
                 ]
               }
             }
    end

    test "structures permissions" do
      assert Query.build_query(%{"view_data_structure" => :none}, @indices) ==
               %{match_none: %{}}

      assert Query.build_query(%{"view_data_structure" => :all}, @indices) ==
               %{
                 bool: %{
                   filter: [%{term: %{"_index" => "structures_idx"}}],
                   must_not: [
                     %{term: %{"confidential" => true}},
                     %{exists: %{field: "deleted_at"}}
                   ]
                 }
               }

      assert Query.build_query(
               %{"view_data_structure" => :all, "manage_confidential_structures" => :all},
               @indices
             ) ==
               %{
                 bool: %{
                   filter: [%{term: %{"_index" => "structures_idx"}}],
                   must_not: %{exists: %{field: "deleted_at"}}
                 }
               }

      assert Query.build_query(%{"view_data_structure" => [1]}, @indices) == %{
               bool: %{
                 filter: [%{term: %{"domain_ids" => 1}}, %{term: %{"_index" => "structures_idx"}}],
                 must_not: [%{term: %{"confidential" => true}}, %{exists: %{field: "deleted_at"}}]
               }
             }

      assert Query.build_query(
               %{"view_data_structure" => [1], "manage_confidential_structures" => :all},
               @indices
             ) == %{
               bool: %{
                 filter: [%{term: %{"domain_ids" => 1}}, %{term: %{"_index" => "structures_idx"}}],
                 must_not: %{exists: %{field: "deleted_at"}}
               }
             }

      assert Query.build_query(
               %{"view_data_structure" => [1], "manage_confidential_structures" => [2, 3]},
               @indices
             ) == %{
               bool: %{
                 filter: [
                   %{term: %{"domain_ids" => 1}},
                   %{
                     bool: %{
                       should: [
                         %{terms: %{"domain_ids" => [2, 3]}},
                         %{term: %{"confidential" => false}}
                       ]
                     }
                   },
                   %{term: %{"_index" => "structures_idx"}}
                 ],
                 must_not: %{exists: %{field: "deleted_at"}}
               }
             }
    end

    test "mixed permissions" do
      assert %{bool: %{should: should, minimum_should_match: 1}} =
               Query.build_query(
                 %{
                   "manage_confidential_business_concepts" => :none,
                   "manage_confidential_structures" => [1, 2],
                   "view_data_structure" => :all,
                   "view_published_business_concepts" => [3]
                 },
                 @indices
               )

      assert [concept_clause, structure_clause] = should

      assert concept_clause == %{
               bool: %{
                 filter: [
                   %{term: %{"domain_ids" => 3}},
                   %{term: %{"_index" => "concepts_idx"}},
                   %{term: %{"status" => "published"}}
                 ],
                 must_not: %{term: %{"confidential.raw" => true}}
               }
             }

      assert structure_clause == %{
               bool: %{
                 filter: [
                   %{
                     bool: %{
                       should: [
                         %{terms: %{"domain_ids" => [1, 2]}},
                         %{term: %{"confidential" => false}}
                       ]
                     }
                   },
                   %{term: %{"_index" => "structures_idx"}}
                 ],
                 must_not: %{exists: %{field: "deleted_at"}}
               }
             }
    end
  end

  describe "build_query/3" do
    test "includes multi_match must clause" do
      permissions = %{"view_published_business_concepts" => :all}
      query_string = "  foo  bar  "

      assert Query.build_query(permissions, @indices, query_string) == %{
               bool: %{
                 must: %{
                   multi_match: %{
                     fields: ["ngram_name*^3"],
                     lenient: true,
                     type: "bool_prefix",
                     fuzziness: "AUTO",
                     query: String.trim(query_string)
                   }
                 },
                 should: [
                   %{
                     multi_match: %{
                       fields: ["name^3"],
                       type: "phrase_prefix",
                       query: String.trim(query_string),
                       boost: 4.0,
                       lenient: true
                     }
                   },
                   %{
                     simple_query_string: %{
                       fields: ["name^3"],
                       query: "\"#{String.trim(query_string)}\"",
                       boost: 4.0,
                       quote_field_suffix: ".exact"
                     }
                   }
                 ],
                 must_not: %{term: %{"confidential.raw" => true}},
                 filter: [
                   %{term: %{"_index" => "concepts_idx"}},
                   %{term: %{"status" => "published"}}
                 ]
               }
             }
    end

    test "includes simple_query_string clause" do
      permissions = %{
        "view_data_structure" => :all,
        "view_published_business_concepts" => :all
      }

      query_string = "\"foo\""

      assert %{
               bool: %{
                 should: [
                   %{
                     bool: %{
                       must: %{
                         simple_query_string: %{
                           fields: ["name^3"],
                           query: "\"foo\"",
                           quote_field_suffix: ".exact"
                         }
                       },
                       filter: [
                         %{term: %{"_index" => "concepts_idx"}},
                         %{term: %{"status" => "published"}}
                       ],
                       must_not: %{term: %{"confidential.raw" => true}}
                     }
                   },
                   %{
                     bool: %{
                       must: %{
                         simple_query_string: %{
                           fields: ["name^3", "original_name^3", "path_joined", "system.name"],
                           query: "\"foo\"",
                           quote_field_suffix: ".exact"
                         }
                       },
                       filter: [%{term: %{"_index" => "structures_idx"}}],
                       must_not: [
                         %{term: %{"confidential" => true}},
                         %{exists: %{field: "deleted_at"}}
                       ]
                     }
                   }
                 ],
                 minimum_should_match: 1
               }
             } == Query.build_query(permissions, @indices, query_string)
    end

    test "with multiple indices" do
      permissions = %{"view_published_business_concepts" => :all, "view_data_structure" => :all}
      query_string = "  foo   bar "

      assert Query.build_query(permissions, @indices, query_string) == %{
               bool: %{
                 minimum_should_match: 1,
                 should: [
                   %{
                     bool: %{
                       must: %{
                         multi_match: %{
                           fields: ["ngram_name*^3"],
                           lenient: true,
                           query: "foo   bar",
                           fuzziness: "AUTO",
                           type: "bool_prefix"
                         }
                       },
                       should: [
                         %{
                           multi_match: %{
                             fields: ["name^3"],
                             type: "phrase_prefix",
                             query: "foo   bar",
                             boost: 4.0,
                             lenient: true
                           }
                         },
                         %{
                           simple_query_string: %{
                             fields: ["name^3"],
                             query: "\"foo   bar\"",
                             boost: 4.0,
                             quote_field_suffix: ".exact"
                           }
                         }
                       ],
                       must_not: %{term: %{"confidential.raw" => true}},
                       filter: [
                         %{term: %{"_index" => "concepts_idx"}},
                         %{term: %{"status" => "published"}}
                       ]
                     }
                   },
                   %{
                     bool: %{
                       must: %{
                         multi_match: %{
                           fields: [
                             "ngram_name*^3",
                             "ngram_original_name*^3",
                             "ngram_path*",
                             "system.name"
                           ],
                           lenient: true,
                           query: "foo   bar",
                           fuzziness: "AUTO",
                           type: "bool_prefix"
                         }
                       },
                       should: [
                         %{
                           multi_match: %{
                             fields: ["name^3", "original_name^3", "path_joined", "system.name"],
                             type: "phrase_prefix",
                             query: "foo   bar",
                             boost: 4.0,
                             lenient: true
                           }
                         },
                         %{
                           simple_query_string: %{
                             fields: ["name^3", "original_name^3"],
                             query: "\"foo   bar\"",
                             boost: 4.0,
                             quote_field_suffix: ".exact"
                           }
                         }
                       ],
                       filter: [%{term: %{"_index" => "structures_idx"}}],
                       must_not: [
                         %{term: %{"confidential" => true}},
                         %{exists: %{field: "deleted_at"}}
                       ]
                     }
                   }
                 ]
               }
             }
    end
  end
end
