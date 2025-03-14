defmodule TdSe.Search.QueryTest do
  use ExUnit.Case

  alias TdSe.Search.Query

  @structures Application.compile_env(:td_se, :index_aliases)[:structures]
  @concepts Application.compile_env(:td_se, :index_aliases)[:concepts]
  @ingests Application.compile_env(:td_se, :index_aliases)[:ingests]

  @indices %{
    @concepts => "concepts_idx",
    @structures => "structures_idx",
    @ingests => "ingests_idx"
  }

  describe "build_query/2" do
    test "when all permissions have scope all" do
      assert Query.build_query(
               %{
                 "manage_confidential_business_concepts" => :all,
                 "manage_confidential_structures" => :all,
                 "view_data_structure" => :all,
                 "view_published_business_concepts" => :all,
                 "view_published_ingests" => :all
               },
               @indices
             ) == %{
               bool: %{
                 minimum_should_match: 1,
                 should: [
                   %{
                     bool: %{
                       must: [
                         %{term: %{"_index" => "concepts_idx"}},
                         %{term: %{"status" => "published"}}
                       ]
                     }
                   },
                   %{
                     bool: %{
                       must: [
                         %{term: %{"_index" => "ingests_idx"}},
                         %{term: %{"status" => "published"}}
                       ]
                     }
                   },
                   %{
                     bool: %{
                       must: [%{term: %{"_index" => "structures_idx"}}],
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
                 "view_published_business_concepts" => :none,
                 "view_published_ingests" => :none
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
                   must: [
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
                   must: [
                     %{term: %{"_index" => "concepts_idx"}},
                     %{term: %{"status" => "published"}}
                   ]
                 }
               }

      assert Query.build_query(%{"view_published_business_concepts" => [1]}, @indices) == %{
               bool: %{
                 must: [
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
                 must: [
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
                 must: [
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
                   must: [%{term: %{"_index" => "structures_idx"}}],
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
                   must: [%{term: %{"_index" => "structures_idx"}}],
                   must_not: %{exists: %{field: "deleted_at"}}
                 }
               }

      assert Query.build_query(%{"view_data_structure" => [1]}, @indices) == %{
               bool: %{
                 must: [%{term: %{"domain_ids" => 1}}, %{term: %{"_index" => "structures_idx"}}],
                 must_not: [%{term: %{"confidential" => true}}, %{exists: %{field: "deleted_at"}}]
               }
             }

      assert Query.build_query(
               %{"view_data_structure" => [1], "manage_confidential_structures" => :all},
               @indices
             ) == %{
               bool: %{
                 must: [%{term: %{"domain_ids" => 1}}, %{term: %{"_index" => "structures_idx"}}],
                 must_not: %{exists: %{field: "deleted_at"}}
               }
             }

      assert Query.build_query(
               %{"view_data_structure" => [1], "manage_confidential_structures" => [2, 3]},
               @indices
             ) == %{
               bool: %{
                 must: [
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

    test "ingests permissions" do
      assert Query.build_query(%{"view_published_ingests" => :none}, @indices) ==
               %{match_none: %{}}

      assert Query.build_query(%{"view_published_ingests" => :all}, @indices) ==
               %{
                 bool: %{
                   must: [
                     %{term: %{"_index" => "ingests_idx"}},
                     %{term: %{"status" => "published"}}
                   ]
                 }
               }

      assert Query.build_query(%{"view_published_ingests" => [1]}, @indices) ==
               %{
                 bool: %{
                   must: [
                     %{term: %{"domain_ids" => 1}},
                     %{term: %{"_index" => "ingests_idx"}},
                     %{term: %{"status" => "published"}}
                   ]
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
                   "view_published_business_concepts" => [3],
                   "view_published_ingests" => :none
                 },
                 @indices
               )

      assert [concept_clause, structure_clause] = should

      assert concept_clause == %{
               bool: %{
                 must: [
                   %{term: %{"domain_ids" => 3}},
                   %{term: %{"_index" => "concepts_idx"}},
                   %{term: %{"status" => "published"}}
                 ],
                 must_not: %{term: %{"confidential.raw" => true}}
               }
             }

      assert structure_clause == %{
               bool: %{
                 must: [
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
      permissions = %{"view_published_ingests" => :all}
      query_string = "  foo  bar  "

      assert %{
               bool: %{
                 must: [
                   %{
                     multi_match: %{
                       fields: ["ngram_name*^3"],
                       lenient: true,
                       type: "bool_prefix",
                       fuzziness: "AUTO"
                     }
                   },
                   %{term: %{"_index" => "ingests_idx"}},
                   %{term: %{"status" => "published"}}
                 ]
               }
             } = Query.build_query(permissions, @indices, query_string)
    end

    test "includes simple_query_string clause" do
      permissions = %{
        "view_published_ingests" => :all,
        "view_data_structure" => :all,
        "view_published_business_concepts" => :all
      }

      query_string = "\"foo\""

      assert %{
               bool: %{
                 should: [
                   %{
                     bool: %{
                       must: [
                         %{simple_query_string: %{fields: ["name*"], query: "\"foo\""}},
                         %{term: %{"_index" => "concepts_idx"}},
                         %{term: %{"status" => "published"}}
                       ],
                       must_not: %{term: %{"confidential.raw" => true}}
                     }
                   },
                   %{
                     bool: %{
                       must: [
                         %{simple_query_string: %{fields: ["name*"], query: "\"foo\""}},
                         %{term: %{"_index" => "ingests_idx"}},
                         %{term: %{"status" => "published"}}
                       ]
                     }
                   },
                   %{
                     bool: %{
                       must: [
                         %{
                           simple_query_string: %{
                             fields: ["name*", "original_name*"],
                             query: "\"foo\""
                           }
                         },
                         %{term: %{"_index" => "structures_idx"}}
                       ],
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
      permissions = %{"view_published_ingests" => :all, "view_data_structure" => :all}
      query_string = "  foo   bar "

      assert %{
               bool: %{
                 minimum_should_match: 1,
                 should: [
                   %{
                     bool: %{
                       must: [
                         %{
                           multi_match: %{
                             fields: ["ngram_name*^3"],
                             lenient: true,
                             query: "foo   bar",
                             fuzziness: "AUTO",
                             type: "bool_prefix"
                           }
                         },
                         %{term: %{"_index" => "ingests_idx"}},
                         %{term: %{"status" => "published"}}
                       ]
                     }
                   },
                   %{
                     bool: %{
                       must: [
                         %{
                           multi_match: %{
                             fields: [
                               "ngram_name*^3",
                               "ngram_original_name*^1.5",
                               "ngram_path*",
                               "system.name"
                             ],
                             lenient: true,
                             query: "foo   bar",
                             fuzziness: "AUTO",
                             type: "bool_prefix"
                           }
                         },
                         %{term: %{"_index" => "structures_idx"}}
                       ],
                       must_not: [
                         %{term: %{"confidential" => true}},
                         %{exists: %{field: "deleted_at"}}
                       ]
                     }
                   }
                 ]
               }
             } = Query.build_query(permissions, @indices, query_string)
    end
  end
end
