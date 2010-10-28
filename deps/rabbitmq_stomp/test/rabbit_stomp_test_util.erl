%%   The contents of this file are subject to the Mozilla Public License
%%   Version 1.1 (the "License"); you may not use this file except in
%%   compliance with the License. You may obtain a copy of the License at
%%   http://www.mozilla.org/MPL/
%%
%%   Software distributed under the License is distributed on an "AS IS"
%%   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
%%   License for the specific language governing rights and limitations
%%   under the License.
%%
%%   The Original Code is RabbitMQ Management Console.
%%
%%   The Initial Developers of the Original Code are Rabbit Technologies Ltd.
%%
%%   Copyright (C) 2010 Rabbit Technologies Ltd.
%%
%%   All Rights Reserved.
%%
%%   Contributor(s): ______________________________________.
%%
-module(rabbit_stomp_test_util).

-include_lib("eunit/include/eunit.hrl").
-include("rabbit_stomp_frame.hrl").

%%--------------------------------------------------------------------
%% Header Parsing Tests
%%--------------------------------------------------------------------

longstr_field_test() ->
    {<<"ABC">>, longstr, <<"DEF">>} =
        rabbit_stomp_util:longstr_field("ABC", "DEF").

%%--------------------------------------------------------------------
%% Frame Parsing Tests
%%--------------------------------------------------------------------

ack_mode_auto_test() ->
    Frame = #stomp_frame{headers = [{"ack", "auto"}]},
    auto = rabbit_stomp_util:ack_mode(Frame).

ack_mode_auto_default_test() ->
    Frame = #stomp_frame{headers = []},
    auto = rabbit_stomp_util:ack_mode(Frame).

ack_mode_client_test() ->
    Frame = #stomp_frame{headers = [{"ack", "client"}]},
    client = rabbit_stomp_util:ack_mode(Frame).

consumer_tag_id_test() ->
    Frame = #stomp_frame{headers = [{"id", "foo"}]},
    {ok, <<"T_foo">>} = rabbit_stomp_util:consumer_tag(Frame).

consumer_tag_destination_test() ->
    Frame = #stomp_frame{headers = [{"destination", "foo"}]},
    {ok, <<"Q_foo">>} = rabbit_stomp_util:consumer_tag(Frame).

consumer_tag_invalid_test() ->
    Frame = #stomp_frame{headers = []},
    {error, missing_destination_header} = rabbit_stomp_util:consumer_tag(Frame).

%%--------------------------------------------------------------------
%% Destination Parsing Tests
%%--------------------------------------------------------------------

valid_queue_test() ->
    {ok, {queue, "test"}} = parse_destination("/queue/test").

valid_topic_test() ->
    {ok, {topic, "test"}} = parse_destination("/topic/test").

valid_exchange_test() ->
    {ok, {exchange, {"test", undefined}}} = parse_destination("/exchange/test").

valid_exchange_with_pattern_test() ->
    {ok, {exchange, {"test", "pattern"}}} =
        parse_destination("/exchange/test/pattern").

queue_with_no_name_test() ->
    {error, {invalid_destination, queue, ""}} = parse_destination("/queue").

topic_with_no_name_test() ->
    {error, {invalid_destination, topic, ""}} = parse_destination("/topic").

exchange_with_no_name_test() ->
    {error, {invalid_destination, exchange, ""}} =
        parse_destination("/exchange").

exchange_default_name_test() ->
    {error, {invalid_destination, exchange, "//foo"}} =
        parse_destination("/exchange//foo").

queue_with_no_name_slash_test() ->
    {error, {invalid_destination, queue, "/"}} = parse_destination("/queue/").

topic_with_no_name_slash_test() ->
    {error, {invalid_destination, topic, "/"}} = parse_destination("/topic/").

exchange_with_no_name_slash_test() ->
    {error, {invalid_destination, exchange, "/"}} =
        parse_destination("/exchange/").

queue_with_invalid_name_test() ->
    {error, {invalid_destination, queue, "/foo/bar"}} =
        parse_destination("/queue/foo/bar").

topic_with_invalid_name_test() ->
    {error, {invalid_destination, topic, "/foo/bar"}} =
        parse_destination("/topic/foo/bar").

exchange_with_invalid_name_test() ->
    {error, {invalid_destination, exchange, "/foo/bar/baz"}} =
        parse_destination("/exchange/foo/bar/baz").

unknown_destination_test() ->
    {error, {unknown_destination, "/blah/boo"}} =
        parse_destination("/blah/boo").

queue_with_escaped_name_test() ->
    {ok, {queue, "te/st"}} = parse_destination("/queue/te%2Fst").

valid_exchange_with_escaped_name_and_pattern_test() ->
    {ok, {exchange, {"te/st", "pa/tt/ern"}}} =
        parse_destination("/exchange/te%2Fst/pa%2Ftt%2Fern").

create_message_id_test() ->
    [<<"baz">>, "@@", "abc", "@@", "123"] =
        rabbit_stomp_util:create_message_id(<<"baz">>, "abc", 123).

parse_valid_message_id_test() ->
    {ok, {<<"bar">>, "abc", 123}} =
        rabbit_stomp_util:parse_message_id("bar@@abc@@123").

parse_invalid_message_id_test() ->
    {error, invalid_message_id} =
        rabbit_stomp_util:parse_message_id("blah").

%%--------------------------------------------------------------------
%% Test Helpers
%%--------------------------------------------------------------------
parse_destination(Destination) ->
    rabbit_stomp_util:parse_destination(Destination).
