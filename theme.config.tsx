import React from "react";
import { DocsThemeConfig } from "nextra-theme-docs";
import { useRouter } from "next/router";
import { useConfig } from "nextra-theme-docs";
import "@feelback/react/styles/feelback.css";
import Image from "next/image";

const config: DocsThemeConfig = {
  logo: (
    <Image
      src={"./logo.svg"}
      alt=""
      width={150}
      height={30}
      className="nx-logo"
    />
  ),
  darkMode: true,
  project: {
    link: "https://github.com/mlabs-haskell/clb",
  },
  footer: {
    text: "CLB Cardano Emulator Documentation"
  },
  sidebar: {
    defaultMenuCollapseLevel: 1,
    autoCollapse: true,
  },
  feedback: {
    content: "",
  },
  editLink: {
    text: "",
  },
  useNextSeoProps() {
    const { asPath } = useRouter();
    if (asPath !== "/") {
      return {
        titleTemplate: "%s | CLB Docs",
      };
    }
  },
  head: () => {
    const { asPath, defaultLocale, locale } = useRouter();
    const { frontMatter } = useConfig();
    const url =
      "https://mlabs-haskell.github.io/clb-docs/" +
      (defaultLocale === locale ? asPath : `/${locale}${asPath}`);

    return (
      <>
        <meta property="og:url" content={url} />
        <meta property="og:title" content={frontMatter.title || "CLB Docs"} />
        <meta
          property="og:description"
          content={frontMatter.description || "CLB Docs for developers"}
        />
        <link
          rel="icon"
          href="/img/icons/favicon.ico"
          type="image/x-icon"
        ></link>
      </>
    );
  },
};

export default config;
